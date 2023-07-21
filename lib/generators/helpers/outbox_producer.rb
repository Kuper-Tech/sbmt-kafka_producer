# frozen_string_literal: true

require "psych"

module KafkaProducer
  module Generators
    module Helpers
      module OutboxProducer
        OUTBOX_CONFIG_PATH = "config/outbox.yml"

        private

        def outbox_config_exists?
          File.exist?(OUTBOX_CONFIG_PATH)
        end

        def update_outbox_producer_file
          return absent_file unless outbox_config_exists?
          return absent_section unless outbox_item_exists?

          modify_outbox_config
        end

        def absent_file
          $stdout.puts "Could not find file config/outbox.yml"
        end

        def absent_section
          $stdout.puts "Could not find section #{name_outbox_item} in config/outbox.yml"
        end

        def load_yaml
          data_yaml = Psych.load_file(OUTBOX_CONFIG_PATH)

          @load_yaml ||= data_yaml
        end

        def name_outbox_item
          "#{path}_outbox_item"
        end

        def outbox_item_exists?
          load_yaml.fetch("default", {}).fetch("outbox_items", {}).fetch(name_outbox_item, false)
        end

        def modify_outbox_config
          transpport_declarations_data = <<~YAML
            transports:
              sbmt/kafka_producer:
                topic: 'need to add a topic'
                kafka:
                  required_acks: -1
          YAML

          pattern = /#{name_outbox_item}.*?(exponential_backoff)\s*\n/m
          inject_into_file OUTBOX_CONFIG_PATH, optimize_indentation(transpport_declarations_data, 6), after: pattern
        end
      end
    end
  end
end
