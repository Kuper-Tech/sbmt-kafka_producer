# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class KafkaClientFactory
      class << self
        def default_client
          @default_client ||= ConnectionPool::Wrapper.new do
            Sbmt::WaterDrop::Producer.new do |config|
              configure_producer(config)
            end
          end
        end

        def build(kafka = {})
          return default_client if kafka.empty?

          ConnectionPool::Wrapper.new do
            Sbmt::WaterDrop::Producer.new do |config|
              configure_producer(config, kafka)
            end
          end
        end

        private

        def configure_producer(kafka_config, kafka_options = {})
          kafka_config.logger = config.logger_class.classify.constantize.new
          kafka_config.kafka = config.to_kafka_options.merge(kafka_options)

          kafka_config.deliver = config.deliver if config.deliver.present?
          kafka_config.wait_on_queue_full = config.wait_on_queue_full if config.wait_on_queue_full.present?
          kafka_config.max_payload_size = config.max_payload_size if config.max_payload_size.present?
          kafka_config.max_wait_timeout = config.max_wait_timeout if config.max_wait_timeout.present?
          kafka_config.wait_timeout = config.wait_timeout if config.wait_timeout.present?
          kafka_config.wait_on_queue_full_timeout = config.wait_on_queue_full_timeout if config.wait_on_queue_full_timeout.present?
        end

        def config
          @config ||= Configs::Producer.new
        end
      end
    end
  end
end
