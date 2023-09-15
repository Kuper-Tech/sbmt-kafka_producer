# frozen_string_literal: true

require "opentelemetry"
require "opentelemetry-common"
require "opentelemetry-instrumentation-base"

require_relative "open_telemetry_tracer"

module Sbmt
  module KafkaProducer
    module Instrumentation
      class OpenTelemetryLoader < ::OpenTelemetry::Instrumentation::Base
        install do |_config|
          OpenTelemetryTracer.enabled = true
        end

        present do
          defined?(OpenTelemetryTracer)
        end
      end
    end
  end
end
