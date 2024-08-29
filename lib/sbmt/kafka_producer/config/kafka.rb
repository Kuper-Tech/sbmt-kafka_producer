# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Config
      class Kafka < Dry::Struct
        transform_keys(&:to_sym)

        # srv1:port1,srv2:port2,...
        SERVERS_REGEXP = /^[a-z\d.\-:]+(,[a-z\d.\-:]+)*$/.freeze

        # https://github.com/karafka/waterdrop/blob/master/lib/waterdrop/config.rb
        KAFKA_CONFIG_KEYS_REMAP = {
          servers: :"bootstrap.servers",
          connect_timeout: :"socket.connection.setup.timeout.ms",
          message_timeout: :"message.timeout.ms",
          ack_timeout: :"request.timeout.ms",
          retry_backoff: :"retry.backoff.ms",
          max_retries: :"message.send.max.retries",
          required_acks: :"request.required.acks"
        }

        attribute :servers, Sbmt::KafkaProducer::Types::String.constrained(format: SERVERS_REGEXP)

        # defaults are rdkafka's
        # see https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md
        attribute :connect_timeout, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(2000)
        attribute :ack_timeout, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(1000)
        attribute :retry_backoff, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(1000)
        attribute :message_timeout, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(55000)
        attribute :required_acks, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(-1)
        attribute :max_retries, Sbmt::KafkaProducer::Types::Coercible::Integer.optional.default(2)

        attribute :kafka_config, Sbmt::KafkaProducer::Types::ConfigAttrs.optional.default({}.freeze)

        def to_kafka_options
          cfg = KAFKA_CONFIG_KEYS_REMAP.each_with_object({}) do |(key, kafka_key), hash|
            hash[kafka_key] = self[key]
          end

          kafka_config.symbolize_keys.merge(cfg)
        end
      end
    end
  end
end
