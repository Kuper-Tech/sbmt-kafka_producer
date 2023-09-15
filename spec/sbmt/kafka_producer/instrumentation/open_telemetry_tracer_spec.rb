# frozen_string_literal: true

require "rails_helper"

describe Sbmt::KafkaProducer::Instrumentation::OpenTelemetryTracer do
  let(:topic_name) { "topic" }
  let(:message) do
    {
      headers: {"some-key" => "value"},
      topic: topic_name,
      payload: "message payload",
      key: "message-key"
    }
  end

  describe "when disabled" do
    before { described_class.enabled = false }

    it "does not trace consumed message" do
      expect(::Sbmt::KafkaProducer::Instrumentation::OpenTelemetryLoader).not_to receive(:instance)

      described_class.new.call(message)
    end
  end

  describe ".trace" do
    let(:tracer) { double("tracer") }
    let(:instrumentation_instance) { double("instrumentation instance") }

    before do
      described_class.enabled = true

      allow(::Sbmt::KafkaProducer::Instrumentation::OpenTelemetryLoader).to receive(:instance).and_return(instrumentation_instance)
      allow(instrumentation_instance).to receive(:tracer).and_return(tracer)
    end

    it "injects context into message headers" do
      expect(tracer).to receive(:in_span).with("topic publish", kind: :producer, attributes: {
        "messaging.destination" => topic_name,
        "messaging.kafka.message_key" => "message-key",
        "messaging.destination_kind" => "topic",
        "messaging.system" => "kafka"
      }).and_yield
      expect(::OpenTelemetry.propagation).to receive(:inject).with(message[:headers])
      described_class.new.call(message)
    end
  end
end
