# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class BaseProducer
      def initialize(topic:, kafka: {})
        @topic = topic
        @pool = OutboxTransportFactory.build(kafka: kafka)
      end

      def call(item, payload)
        @pool.with do |client|
          client.produce_sync(topic: @topic, item: item, payload: payload)
        end
      end
    end
  end
end
