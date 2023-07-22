# frozen_string_literal: true

require "rails/generators/base"

module KafkaProducer
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      CONFIG_PATH = "config/kafka_producer.yml"

      def create_kafka_producer_yml
        copy_file "kafka_producer.yml", CONFIG_PATH
      end
    end
  end
end
