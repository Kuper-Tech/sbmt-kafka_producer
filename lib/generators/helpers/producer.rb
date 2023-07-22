# frozen_string_literal: true

module KafkaProducer
  module Generators
    module Helpers
      module Producer
        private

        def create_producer_file(path)
          template current_template, File.join("app/producers", "#{path}_producer.rb")
        end

        def current_template
          if producer_type == "async"
            "async_producer.rb"
          else
            "producer.rb"
          end
        end
      end
    end
  end
end
