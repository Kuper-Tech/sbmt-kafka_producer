# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Config
      class Auth < Dry::Struct
        transform_keys(&:to_sym)

        AVAILABLE_AUTH_KINDS = %w[plaintext sasl_plaintext].freeze
        DEFAULT_AUTH_KIND = "plaintext"

        AVAILABLE_SASL_MECHANISMS = %w[PLAIN SCRAM-SHA-256 SCRAM-SHA-512].freeze
        DEFAULT_SASL_MECHANISM = "SCRAM-SHA-512"

        attribute :kind, Sbmt::KafkaProducer::Types::Strict::String
          .default(DEFAULT_AUTH_KIND)
          .enum(*AVAILABLE_AUTH_KINDS)
        attribute? :sasl_mechanism, Sbmt::KafkaProducer::Types::Strict::String
          .default(DEFAULT_SASL_MECHANISM)
          .enum(*AVAILABLE_SASL_MECHANISMS)
        attribute? :sasl_username, Sbmt::KafkaProducer::Types::Strict::String
        attribute? :sasl_password, Sbmt::KafkaProducer::Types::Strict::String

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
            raise Anyway::Config::ValidationError, "unknown auth kind: #{kind}"
          end

          opts.symbolize_keys
        end

        private

        def ensure_options_are_valid
          raise Anyway::Config::ValidationError, "unknown auth kind: #{kind}" unless AVAILABLE_AUTH_KINDS.include?(kind)

          case kind
          when "sasl_plaintext"
            raise Anyway::Config::ValidationError, "sasl_username is required for #{kind} auth kind" if sasl_username.blank?
            raise Anyway::Config::ValidationError, "sasl_password is required for #{kind} auth kind" if sasl_password.blank?
            raise Anyway::Config::ValidationError, "sasl_mechanism is required for #{kind} auth kind" if sasl_mechanism.blank?
            raise Anyway::Config::ValidationError, "invalid sasl_mechanism for #{kind} auth kind, available options are: [#{AVAILABLE_SASL_MECHANISMS.join(",")}]" unless AVAILABLE_SASL_MECHANISMS.include?(sasl_mechanism)
          end
        end
      end
    end
  end
end
