# frozen_string_literal: true

require "generators/base_producer_generator"

module KafkaProducer
  module Generators
    class ProducerGenerator < BaseProducerGenerator
      argument :producer_type, type: :string, default: "sync", banner: "async"
      source_root File.expand_path("templates", __dir__)

      def kind
        :producer
      end
    end
  end
end
