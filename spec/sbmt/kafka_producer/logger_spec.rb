# frozen_string_literal: true

describe Sbmt::KafkaProducer::Logger do
  context "when logger" do
    let(:msg) { "message" }

    it "receives debug and calls Rails.logger" do
      expect(Rails.logger).to receive(:debug).with(msg)
      described_class.new.debug(msg)
    end

    it "receives info and calls Rails.logger" do
      expect(Rails.logger).to receive(:info).with(msg)
      described_class.new.info(msg)
    end

    it "receives warn and calls Rails.logger" do
      expect(Rails.logger).to receive(:warn).with(msg)
      described_class.new.warn(msg)
    end

    it "receives error and calls Rails.logger" do
      expect(Rails.logger).to receive(:error).with(msg)
      described_class.new.error(msg)
    end

    it "receives fatal and calls Rails.logger" do
      expect(Rails.logger).to receive(:fatal).with(msg)
      described_class.new.fatal(msg)
    end
  end
end
