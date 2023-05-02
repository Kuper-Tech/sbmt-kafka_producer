# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class BaseProducer
      extend Dry::Initializer

      # TODO: will be configured in DEX-1075
      IGNORE_KAFKA_ERRORS = true

      option :client, default: -> { KafkaClientFactory.default_client }
      option :topic

      def publish(payload, options = {})
        around_publish do
          client.produce_sync(payload: payload, **options.merge(topic: topic))
        end

        true
      rescue Sbmt::WaterDrop::Errors::ProduceError => e
        log_error(e)
        false
      end

      private

      def logger
        ::Sbmt::KafkaProducer.logger
      end

      def process_message(_message)
        raise NotImplementedError, "Implement this in a subclass"
      end

      def around_publish
        with_sentry_transaction { yield }
      end

      def with_sentry_transaction
        return yield unless ::Sentry.initialized?

        transaction = ::Sentry.start_transaction(
          name: "Karafka/#{self.class.name}",
          op: "kafka-producer"
        )

        # Tracing is disabled by config
        return yield unless transaction

        result = nil
        transaction.with_child_span do |span|
          span.set_data(:topic, topic)
          result = yield
        end

        transaction.finish
        result
      end

      def ignore_kafka_errors?
        IGNORE_KAFKA_ERRORS.to_s == "true"
      end

      def log_error(error)
        return true if ignore_kafka_errors?

        logger.error "KAFKA ERROR: #{error.message}\n#{error.backtrace.join("\n")}"
      end
    end
  end
end
