# frozen_string_literal: true

module KafkaProducer
  module Generators
    module Helpers
      module Config
        KAFKA_PRODUCER_CONFIG_PATH = "config/kafka_producer.yml"

        private

        def config_exists?
          File.exist?(KAFKA_PRODUCER_CONFIG_PATH)
        end

        def create_config_with_template(template_name)
          template template_name, File.join(KAFKA_PRODUCER_CONFIG_PATH)
        end
      end
    end
  end
end
