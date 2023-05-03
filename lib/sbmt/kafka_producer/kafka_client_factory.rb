# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class KafkaClientFactory
      # TODO: will be configured in DEX-1075
      PODUCER_DELIVER = true
      PRODUCER_WAIT_ON_QUEUE_FULL = false

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

        def kafka_config
          # TODO: will be configured in DEX-1075
          # Sbmt::KafkaProducer::Configs::KafkaConfig.as_env
          {seed_brokers: "kafka://kafka:9092", producer: {connect_timeout: ""}}
        end

        def configure_producer(config, kafka_options = {})
          config.deliver = PODUCER_DELIVER
          config.logger = Sbmt::KafkaProducer.logger
          config.wait_on_queue_full = PRODUCER_WAIT_ON_QUEUE_FULL
          config.kafka = base_kafka_options.merge(kafka_options)
        end

        def base_kafka_options
          {
            "bootstrap.servers": kafka_config[:seed_brokers].split(",").map { |s| s.delete_prefix("kafka://") }.join(",")
          }
        end
      end
    end
  end
end
