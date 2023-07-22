# frozen_string_literal: true

require "rails/generators/named_base"
require "psych"

module KafkaProducer
  module Generators
    class OutboxProducerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      OUTBOX_CONFIG_PATH = "config/outbox.yml"

      def insert_outbox_producer
        return section_missing unless outbox_item_exists?

        pattern = /#{item_name}.*?(exponential_backoff)\s*\n/m
        inject_into_file OUTBOX_CONFIG_PATH, optimize_indentation(template, 6), after: pattern, force: true
      end

      private

      def load_yaml
        @load_yaml ||= Psych.load_file(OUTBOX_CONFIG_PATH)
      end

      def item_name
        "#{name}_outbox_item"
      end

      def section_missing
        $stdout.puts "Could not find section #{item_name} in config/outbox.yml"
      end

      def outbox_item_exists?
        load_yaml.dig("default", "outbox_items", item_name).present?
      end

      def template
        <<~YAML
          transports:
            sbmt/kafka_producer:
              topic: 'need to add a topic'
        YAML
      end
    end
  end
end
