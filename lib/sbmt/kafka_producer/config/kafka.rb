# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Config
      class Kafka < Dry::Struct
        transform_keys(&:to_sym)

        # srv1:port1,srv2:port2,...
        SERVERS_REGEXP = /^[a-z\d.\-:]+(,[a-z\d.\-:]+)*$/.freeze

        attribute :servers, Sbmt::KafkaProducer::Types::String.constrained(format: SERVERS_REGEXP)

        # defaults are rdkafka's
        # see https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md
        attribute :connect_timeout, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(1)
        attribute :ack_timeout, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(1)
        attribute :required_acks, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(-1)
        attribute :max_retries, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(2)
        attribute :retry_backoff, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(1)

        attribute :kafka_config, Sbmt::KafkaProducer::Types::ConfigAttrs.optional.default({}.freeze)

        def to_kafka_options
          kafka_config.merge(
            "bootstrap.servers": servers,
            "socket.connection.setup.timeout.ms": connect_timeout.to_f * 1000,
            "request.timeout.ms": ack_timeout.to_f * 1000,
            "request.required.acks": required_acks,
            "message.send.max.retries": max_retries,
            "retry.backoff.ms": retry_backoff.to_f * 1000
          ).symbolize_keys
        end
      end
    end
  end
end
