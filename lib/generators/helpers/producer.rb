# frozen_string_literal: true

module KafkaProducer
  module Generators
    module Helpers
      module Producer
        private

        def create_producer_file(path)
          template "application_producer.rb", File.join("app/producers", "application_producer.rb")
          template "producer.rb", File.join("app/producers", "#{path}_producer.rb")
        end
      end
    end
  end
end
