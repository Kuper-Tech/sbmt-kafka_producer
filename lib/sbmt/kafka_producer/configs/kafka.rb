# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Configs
      class Kafka < Anyway::Config
        SERVERS_REGEXP = /^[\w\d.\-:,]+$/.freeze

        config_name :kafka_producer_kafka
        attr_config :servers, kafka_config: {}

        required :servers
        coerce_types servers: {type: :string, array: false}

        on_load :ensure_options_are_valid

        def to_kafka_options
          custom_kafka_config.merge(
            "bootstrap.servers": servers
          ).symbolize_keys
        end

        private

        def custom_kafka_config
          {
            "socket.connection.setup.timeout.ms": kafka_config.dig("connect_timeout").to_f * 1000,
            "request.timeout.ms": kafka_config.dig("ack_timeout").to_f * 1000,
            "request.required.acks": kafka_config.dig("required_acks"),
            "message.send.max.retries": kafka_config.dig("max_retries"),
            "retry.backoff.ms": kafka_config.dig("retry_backoff").to_f * 1000
          }
        end

        def ensure_options_are_valid
          raise_validation_error "invalid servers: #{servers}, should be in format: \"host1:port1,host2:port2,...\"" unless SERVERS_REGEXP.match?(servers)
        end
      end
    end
  end
end
