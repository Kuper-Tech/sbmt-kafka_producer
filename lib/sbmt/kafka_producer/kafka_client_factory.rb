# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class KafkaClientFactory
      CLIENTS_REGISTRY_MUTEX = Mutex.new
      CLIENTS_REGISTRY = {}

      class << self
        def default_client
          @default_client ||= ConnectionPool::Wrapper.new do
            WaterDrop::Producer.new do |config|
              configure_client(config)
            end
          end
        end

        def build(kafka_options = {})
          return default_client if kafka_options.empty?

          fetch_client(kafka_options) do
            ConnectionPool::Wrapper.new do
              WaterDrop::Producer.new do |config|
                configure_client(config, kafka_options)
              end
            end
          end
        end

        private

        def fetch_client(kafka_options)
          key = Digest::SHA1.hexdigest(Marshal.dump(kafka_options))
          return CLIENTS_REGISTRY[key] if CLIENTS_REGISTRY.key?(key)

          CLIENTS_REGISTRY_MUTEX.synchronize do
            return CLIENTS_REGISTRY[key] if CLIENTS_REGISTRY.key?(key)
            CLIENTS_REGISTRY[key] = yield
          end
        end

        def configure_client(kafka_config, kafka_options = {})
          kafka_config.logger = config.logger_class.classify.constantize.new
          kafka_config.kafka = config.to_kafka_options.merge(custom_kafka_config(kafka_options)).symbolize_keys

          kafka_config.middleware = Instrumentation::TracingMiddleware.new

          kafka_config.deliver = config.deliver if config.deliver.present?
          kafka_config.wait_on_queue_full = config.wait_on_queue_full if config.wait_on_queue_full.present?
          kafka_config.max_payload_size = config.max_payload_size if config.max_payload_size.present?
          kafka_config.max_wait_timeout = config.max_wait_timeout if config.max_wait_timeout.present?
          kafka_config.wait_on_queue_full_timeout = config.wait_on_queue_full_timeout if config.wait_on_queue_full_timeout.present?

          kafka_config.monitor.subscribe(config.metrics_listener_class.classify.constantize.new)
        end

        def custom_kafka_config(kafka_options)
          kafka_options = kafka_options.symbolize_keys
          short_options = kafka_options.extract!(*Config::Kafka::KAFKA_CONFIG_KEYS_REMAP.keys)
          cfg = short_options.transform_keys(Config::Kafka::KAFKA_CONFIG_KEYS_REMAP)
          kafka_options.merge!(cfg)
        end

        def config
          Config::Producer
        end
      end
    end
  end
end
