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
          kafka_config.merge(
            "bootstrap.servers": servers
          ).symbolize_keys
        end

        private

        def ensure_options_are_valid
          raise_validation_error "invalid servers: #{servers}, should be in format: \"host1:port1,host2:port2,...\"" unless SERVERS_REGEXP.match?(servers)
        end
      end
    end
  end
end
