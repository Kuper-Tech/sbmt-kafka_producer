# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class OutboxProducer < Sbmt::KafkaProducer::BaseProducer
      def call(outbox_item, payload)
        sync_publish!(payload, **outbox_item.options)
      end
    end
  end
end
