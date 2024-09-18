# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class BaseProducer
      extend Dry::Initializer

      MSG_SUCCESS = "Message has been successfully sent to Kafka"

      option :client, default: -> { KafkaClientFactory.default_client }
      option :topic

      def sync_publish!(payload, options = {})
        report, produce_duration = around_publish do
          measure_time do
            client.produce_sync(payload: payload, **options.merge(topic: topic))
          end
        end
        log_success(report, produce_duration)
        true
      end

      def sync_publish(payload, options = {})
        sync_publish!(payload, options)
        true
      rescue WaterDrop::Errors::ProduceError => e
        log_error(e)
        false
      end

      def async_publish!(payload, options = {})
        around_publish do
          client.produce_async(payload: payload, **options.merge(topic: topic))
        end
        true
      end

      def async_publish(payload, options = {})
        async_publish!(payload, options)
        true
      rescue WaterDrop::Errors::ProduceError => e
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
        return yield unless defined?(::Sentry)
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

        log_tags = {stacktrace: error.backtrace.join("\n")}

        logger.tagged(log_tags) do
          logger.send(:error, "KAFKA ERROR: #{format_exception_error(error)}")
        end

        ErrorTracker.error(error)
      end

      def log_success(report, produce_duration)
        log_tags = {kafka: log_tags(report, produce_duration)}

        log_with_tags(log_tags)
      end

      def format_exception_error(error)
        text = "#{format_exception_error(error.cause)}. " if with_cause?(error)

        if error.respond_to?(:message)
          "#{text}#{error.class.name} #{error.message}"
        else
          "#{text}#{error}"
        end
      end

      def with_cause?(error)
        error.respond_to?(:cause) && error.cause.present?
      end

      def log_tags(report, produce_duration)
        {
          topic: report.topic_name,
          partition: report.partition,
          offset: report.offset,
          produce_duration_ms: produce_duration
        }
      end

      def log_with_tags(log_tags)
        return unless logger.respond_to?(:tagged)

        logger.tagged(log_tags) do
          logger.send(:info, MSG_SUCCESS)
        end
      end

      def measure_time
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = yield
        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        elapsed_time = end_time - start_time

        [result, elapsed_time]
      end

      def config
        Config::Producer
      end
    end
  end
end
