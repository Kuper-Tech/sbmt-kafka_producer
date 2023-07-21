# frozen_string_literal: true

require "generators/base_producer_generator"

module KafkaProducer
  module Generators
    class OutboxProducerGenerator < BaseProducerGenerator
      source_root File.expand_path("templates", __dir__)

      def kind
        :outbox_producer
      end
    end
  end
end
