# frozen_string_literal: true

describe Sbmt::KafkaProducer::ErrorTracker do
  let(:error) { StandardError.new("wrong attr") }
  let(:message) { "Add new error" }
  let(:params) { {response: "qwerty"} }

  describe ".error" do
    it "is exception" do
      expect(Sentry).to receive(:capture_exception).with(error, level: :error)
      described_class.error(error)
    end

    it "is message" do
      expect(Sentry).to receive(:capture_message).with(message, level: :error)
      described_class.error(message)
    end
  end
end
