# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class OutboxTransportFactory
      class << self
        def build(topic:, kafka: {})
          OutboxProducer.new(topic: topic, client: KafkaClientFactory.build(kafka))
        end
      end
    end
  end
end
