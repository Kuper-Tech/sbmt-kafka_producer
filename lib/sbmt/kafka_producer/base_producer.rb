# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class BaseProducer
      extend Dry::Initializer

      option :client, default: -> { KafkaClientFactory.default_client }
      option :topic

      def sync_publish!(payload, options = {})
        around_publish do
          client.produce_sync(payload: payload, **options.merge(topic: topic))
        end
      end

      def sync_publish(payload, options = {})
        sync_publish!(payload, options)
        true
      rescue Sbmt::WaterDrop::Errors::ProduceError => e
        log_error(e)
        false
      end

      def async_publish!(payload, options = {})
        around_publish do
          client.produce_async(payload: payload, **options.merge(topic: topic))
        end
      end

      def async_publish(payload, options = {})
        async_publish!(payload, options)
        true
      rescue Sbmt::WaterDrop::Errors::ProduceError => e
        log_error(e)
        false
      end

      private

      def logger
        ::Sbmt::KafkaProducer.logger
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
        config.ignore_kafka_error.to_s == "true"
      end

      def log_error(error)
        return true if ignore_kafka_errors?

        logger.error "KAFKA ERROR: #{error.message}\n#{error.backtrace.join("\n")}"
        Sentry.capture_exception(error, level: "error") if ::Sentry.initialized?
      end

      def config
        Config::Producer
      end
    end
  end
end
