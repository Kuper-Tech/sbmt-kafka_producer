# frozen_string_literal: true

require "rails/generators"
require "generators/kafka_producer/concerns/configuration"

module KafkaProducer
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Concerns::Configuration

      source_root File.expand_path("templates", __dir__)

      def create_kafka_producer_yml
        copy_file "kafka_producer.yml", CONFIG_PATH
      end
    end
  end
end
