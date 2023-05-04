# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Configs
      class Auth < Anyway::Config
        config_name :kafka_producer_auth

        attr_config :sasl_mechanism, :sasl_username, :sasl_password, kind: "plaintext"

        VALID_AUTH_KINDS = %w[plaintext sasl_plaintext].freeze
        VALID_SASL_MECHANISMS = %w[PLAIN SCRAM-SHA-256 SCRAM-SHA-512].freeze

        attr_config :sasl_mechanism, :sasl_username, :sasl_password, kind: "plaintext"

        on_load :ensure_options_are_valid

        def to_kafka_options
          ensure_options_are_valid

          opts = {}

          case kind
          when "sasl_plaintext"
            opts.merge!(
              "security.protocol": kind,
              "sasl.mechanism": sasl_mechanism,
              "sasl.username": sasl_username,
              "sasl.password": sasl_password
            )
          when "plaintext"
            opts[:"security.protocol"] = kind
          else
            raise_validation_error "unknown auth kind: #{kind}"
          end

          opts.symbolize_keys
        end

        private

        def ensure_options_are_valid
          raise_validation_error "unknown auth kind: #{kind}" unless VALID_AUTH_KINDS.include?(kind)

          case kind
          when "sasl_plaintext"
            raise_validation_error "sasl_username is required for #{kind} auth kind" if sasl_username.blank?
            raise_validation_error "sasl_password is required for #{kind} auth kind" if sasl_password.blank?
            raise_validation_error "sasl_mechanism is required for #{kind} auth kind" if sasl_mechanism.blank?
            raise_validation_error "invalid sasl_mechanism for #{kind} auth kind, available options are: [#{VALID_SASL_MECHANISMS.join(",")}]" unless VALID_SASL_MECHANISMS.include?(sasl_mechanism)
          end
        end
      end
    end
  end
end
