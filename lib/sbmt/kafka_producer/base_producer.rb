# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class BaseProducer
      extend Dry::Initializer

      option :client, default: -> { KafkaClientFactory.default_client }
      option :topic

      def publish(payload, options = {})
        client.produce_sync(payload: payload, **options.merge(topic: topic))
      end
    end
  end
end
