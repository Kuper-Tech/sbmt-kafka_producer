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
          return config_missing unless outbox_config_exists?
          return section_missing unless outbox_item_exists?

          modify_outbox_config
        end

        def config_missing
          $stdout.puts "Could not find file config/outbox.yml"
        end

        def section_missing
          $stdout.puts "Could not find section #{item_name} in config/outbox.yml"
        end

        def load_yaml
          @load_yaml ||= Psych.load_file(OUTBOX_CONFIG_PATH)
        end

        def item_name
          "#{path}_outbox_item"
        end

        def outbox_item_exists?
          load_yaml.fetch("default", {}).fetch("outbox_items", {}).fetch(item_name, false)
        end

        def modify_outbox_config
          transpport_declarations_data = <<~YAML
            transports:
              sbmt/kafka_producer:
                topic: 'need to add a topic'
          YAML

          pattern = /#{item_name}.*?(exponential_backoff)\s*\n/m
          inject_into_file OUTBOX_CONFIG_PATH, optimize_indentation(transpport_declarations_data, 6), after: pattern
        end
      end
    end
  end
end
