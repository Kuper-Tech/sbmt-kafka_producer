# frozen_string_literal: true

require "generators/kafka_producer"

module KafkaProducer
  module Generators
    class InstallGenerator < Base
      source_root File.expand_path("templates", __dir__)

      class_option :skip_config, type: :boolean, default: false, desc: "Skip creating config/kafka_producer.yml"

      def check_installed
        if config_exists?
          return if no?("kafka_producer.yml already exists, continue?")
        end

        create_config
      end

      private

      def create_config
        return if options[:skip_config]

        create_config_with_template("kafka_producer.yml")
      end
    end
  end
end
