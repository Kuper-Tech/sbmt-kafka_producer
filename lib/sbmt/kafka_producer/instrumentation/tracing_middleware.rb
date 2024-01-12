# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Instrumentation
      class TracingMiddleware < ::WaterDrop::Middleware
        def initialize
          super

          append(OpenTelemetryTracer.new) if defined?(OpenTelemetryTracer)
        end
      end
    end
  end
end
