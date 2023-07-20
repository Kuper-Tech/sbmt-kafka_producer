# frozen_string_literal: true

module KafkaProducer
  module Generators
    module Helpers
      module Producer
        APPLICATION_PRODUCER_PATH = "app/producers/application_producer.rb"

        private

        def application_producer_exists?
          File.exist?(APPLICATION_PRODUCER_PATH)
        end

        def create_producer_file(path)
          template "application_producer.rb", File.join(APPLICATION_PRODUCER_PATH) unless application_producer_exists?
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
