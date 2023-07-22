# frozen_string_literal: true

require "rails/generators/named_base"

module KafkaProducer
  module Generators
    class ProducerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :producer_type, type: :string, banner: "async or sync"
      argument :topic, type: :string, banner: "topic"

      def insert_producer_class
        template "producer.rb.erb", "app/producers/#{file_path}_producer.rb"
      end
    end
  end
end
