# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class Railtie < Rails::Railtie
      config.before_initialize do
        YabedaConfigurer.configure
      end

      initializer "sbmt_kafka_producer_opentelemetry_init.configure_rails_initialization",
        after: "opentelemetry.configure" do
        require "sbmt/kafka_producer/instrumentation/open_telemetry_loader" if defined?(::OpenTelemetry)
      end
    end
  end
end
