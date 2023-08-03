# frozen_string_literal: true

require "rails/generators"

module KafkaProducer
  module Generators
    class OutboxProducerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def insert_outbox_producer
        generate "outbox:transport", "#{item_name.underscore} sbmt/kafka_producer --kind outbox"
      end

      private

      def item_name
        file_path
      end
    end
  end
end
