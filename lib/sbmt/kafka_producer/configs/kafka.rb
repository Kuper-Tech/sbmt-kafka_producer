# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Configs
      class Kafka < Anyway::Config
        SERVERS_REGEXP = /^[\w\d.\-:,]+$/.freeze

        config_name :kafka_producer_kafka
        attr_config :servers, :connect_timeout, :ack_timeout,
          :required_acks, :max_retries, :retry_backoff,
          kafka_config: {}

        required :servers
        coerce_types servers: {type: :string, array: false}

        on_load :ensure_options_are_valid

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

        private

        def ensure_options_are_valid
          raise_validation_error "invalid servers: #{servers}, should be in format: \"host1:port1,host2:port2,...\"" unless SERVERS_REGEXP.match?(servers)
          raise_validation_error "invalid connect_timeout: cannot be empty" unless connect_timeout&.is_a?(Integer)
          raise_validation_error "invalid ack_timeout: cannot be empty" unless ack_timeout&.is_a?(Integer)
          raise_validation_error "invalid required_acks: cannot be empty" unless required_acks&.is_a?(Integer)
          raise_validation_error "invalid max_retries: cannot be empty" unless max_retries&.is_a?(Integer)
          raise_validation_error "invalid retry_backoff: cannot be empty" unless retry_backoff&.is_a?(Integer)
        end
      end
    end
  end
end
