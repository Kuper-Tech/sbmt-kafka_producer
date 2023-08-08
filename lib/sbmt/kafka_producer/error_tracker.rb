# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class ErrorTracker
      class << self
        def error(arr)
          logging(:error, arr)
        end

        private

        def logging(level, arr)
          sentry_logging(level, arr) if ::Sentry.initialized?
        end

        def sentry_logging(level, arr)
          Sentry.with_scope do |_scope|
            if arr.is_a?(Exception)
              Sentry.capture_exception(arr, level: level)
            else
              Sentry.capture_message(arr, level: level)
            end
          end
        end
      end
    end
  end
end
