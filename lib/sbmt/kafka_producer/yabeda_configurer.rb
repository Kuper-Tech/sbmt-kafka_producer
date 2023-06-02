# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class YabedaConfigurer
      SIZE_BUCKETS = [1, 10, 100, 1000, 10_000, 100_000, 1_000_000].freeze
      LATENCY_BUCKETS = [0.0001, 0.001, 0.01, 0.1, 1.0, 10, 100, 1000].freeze

      def self.configure
        Yabeda.configure do
          group :kafka_api do
            counter :calls,
              tags: %i[client broker api],
              comment: "API calls"
            histogram :latency,
              tags: %i[client broker api],
              buckets: LATENCY_BUCKETS,
              comment: "API latency"
            histogram :request_size,
              tags: %i[client broker api],
              buckets: SIZE_BUCKETS,
              comment: "API request size"
            histogram :response_size,
              tags: %i[client broker api],
              buckets: SIZE_BUCKETS,
              comment: "API response size"
            counter :errors,
              tags: %i[client broker api],
              comment: "API errors"
          end

          group :kafka_producer do
            counter :produced_messages,
              tags: %i[client topic],
              comment: "Messages produced"
            histogram :message_size,
              tags: %i[client topic],
              buckets: SIZE_BUCKETS,
              comment: "Producer message size"
            histogram :buffer_size,
              tags: %i[client],
              buckets: SIZE_BUCKETS,
              comment: "Producer buffer size"
            counter :produce_errors,
              tags: %i[client topic],
              comment: "Produce errors"
            counter :deliver_errors,
              tags: %i[client topic],
              comment: "Produce deliver error"
            histogram :deliver_latency,
              tags: %i[client topic],
              buckets: LATENCY_BUCKETS,
              comment: "Produce delivery latency"
            counter :deliver_messages,
              tags: %i[client topic],
              comment: "Total count of delivered messages produced"
          end
        end
      end
    end
  end
end
