# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Configs
      class Producer < Anyway::Config
        config_name :kafka_producer

        attr_config :ignore_kafka_error, :deliver, :wait_on_queue_full,
          :max_payload_size, :max_wait_timeout, :wait_timeout,
          :wait_on_queue_full_timeout,
          auth: {}, kafka: {},
          logger_class: "::Sbmt::KafkaProducer::Logger"

        coerce_types ignore_kafka_error: :boolean,
          deliver: :boolean, wait_on_queue_full: :boolean,
          max_payload_size: :integer, max_wait_timeout: :integer,
          wait_timeout: :float, wait_on_queue_full_timeout: :float
        coerce_types kafka: {config: Kafka}
        coerce_types auth: {config: Auth}

        def to_kafka_options
          kafka.to_kafka_options
            .merge(auth.to_kafka_options)
        end
      end
    end
  end
end
