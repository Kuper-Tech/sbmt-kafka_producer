# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class OutboxTransportFactory
      class << self
        def build(kafka: {})
          if kafka.empty?
            default_client
          else
            ConnectionPool.new do
              Sbmt::WaterDrop::Producer.new do |config|
                setup(config, kafka: kafka)
              end
            end
          end
        end

        def default_client
          @default_client ||= ConnectionPool.new do
            Sbmt::WaterDrop::Producer.new do |config|
              setup(config)
            end
          end
        end

        def setup(config, kafka: {})
          config.deliver = Sbmt::KafkaProducer.deliver
          config.kafka = Sbmt::KafkaProducer.kafka.merge(kafka)
        end
      end
    end
  end
end
