# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Config
      class Producer < Anyway::Config
        class << self
          # Make it possible to access a singleton config instance
          # via class methods (i.e., without explicitly calling `instance`)
          delegate_missing_to :instance

          def coerce_to(struct)
            lambda do |raw_attrs|
              struct.new(**raw_attrs)
            rescue Dry::Types::SchemaError => e
              raise_validation_error "cannot parse #{struct}: #{e.message}"
            end
          end

          private

          # Returns a singleton config instance
          def instance
            @instance ||= new
          end
        end

        config_name :kafka_producer

        attr_config :deliver, :wait_on_queue_full,
          :max_payload_size, :max_wait_timeout,
          :wait_on_queue_full_timeout,
          auth: {}, kafka: {},
          logger_class: "::Sbmt::KafkaProducer::Logger",
          metrics_listener_class: "::Sbmt::KafkaProducer::Instrumentation::YabedaMetricsListener"

        coerce_types deliver: :boolean, wait_on_queue_full: :boolean,
          max_payload_size: :integer, max_wait_timeout: :integer,
          wait_on_queue_full_timeout: :integer
        coerce_types kafka: coerce_to(Kafka)
        coerce_types auth: coerce_to(Auth)

        def to_kafka_options
          auth.to_kafka_options
            .merge(kafka.to_kafka_options)
        end
      end
    end
  end
end
