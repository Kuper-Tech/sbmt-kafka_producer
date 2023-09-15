# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Instrumentation
      class OpenTelemetryTracer
        class << self
          def enabled?
            !!@enabled
          end

          attr_writer :enabled
        end

        def enabled?
          self.class.enabled?
        end

        def call(message)
          return message unless enabled?

          topic = message[:topic]
          attributes = {
            "messaging.system" => "kafka",
            "messaging.destination" => topic,
            "messaging.destination_kind" => "topic"
          }

          message_key = extract_message_key(message[:key])
          attributes["messaging.kafka.message_key"] = message_key if message_key

          message[:headers] ||= {}

          tracer.in_span("#{topic} publish", attributes: attributes, kind: :producer) do
            ::OpenTelemetry.propagation.inject(message[:headers])
          end

          message
        end

        private

        def tracer
          ::Sbmt::KafkaProducer::Instrumentation::OpenTelemetryLoader.instance.tracer
        end

        def extract_message_key(key)
          # skip encode if already valid utf8
          return key if key.nil? || (key.encoding == Encoding::UTF_8 && key.valid_encoding?)

          key.encode(Encoding::UTF_8)
        rescue Encoding::UndefinedConversionError
          nil
        end
      end
    end
  end
end
