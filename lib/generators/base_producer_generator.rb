# frozen_string_literal: true

require "rails/generators/named_base"
require_relative "kafka_producer"

module KafkaProducer
  module Generators
    class BaseProducerGenerator < NamedBase
      class_option :skip_config, type: :boolean, default: false, desc: "Skip modifying config/kafka_producer.yml"
      class_option :skip_producer, type: :boolean, default: false, desc: "Skip creating producer"
      class_option :skip_config, type: :boolean, default: false, desc: "Skip modifying config/outbox.yml"

      def initial_setup
        return if config_exists?

        generate "kafka_producer:install"
      end

      def create_producer
        return if options[:skip_producer]

        create_producer_file(path) if producer?
        update_outbox_producer_file if outbox_producer?
      end

      private

      def kind
        raise NotImplementedError, "implement this in a subsclass, possible values are :producer or :outbox_producer"
      end

      def path
        file_path
      end

      def namespaced_class_name
        file_path.camelize + "Producer"
      end

      def producer?
        kind == :producer
      end

      def outbox_producer?
        kind == :outbox_producer
      end
    end
  end
end
