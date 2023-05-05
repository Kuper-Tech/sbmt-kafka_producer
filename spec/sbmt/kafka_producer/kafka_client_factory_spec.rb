# frozen_string_literal: true

describe Sbmt::KafkaProducer::KafkaClientFactory do
  describe ".default_client" do
    it "returns a ConnectionPool::Wrapper with a WaterDrop::Producer inside" do
      expect(described_class.default_client.with { |producer| producer }).to be_instance_of(Sbmt::WaterDrop::Producer)
    end
  end

  describe ".build" do
    context "when passed an empty hash" do
      it "returns the default client" do
        expect(described_class.build({})).to eq(described_class.default_client)
      end
    end

    context "when passed a kafka configuration hash" do
      let(:kafka_config) { {seed_brokers: "kafka://localhost:9092", producer: {connect_timeout: "10s"}} }

      it "returns a ConnectionPool::Wrapper with a WaterDrop::Producer inside" do
        expect(described_class.build(kafka_config).with { |producer| producer }).to be_instance_of(Sbmt::WaterDrop::Producer)
      end
    end
  end

  describe ".configure_client" do
    let(:logger) { instance_double(Logger) }

    before do
      allow(Sbmt::KafkaProducer).to receive(:logger).and_return(logger)
    end

    it "configures the client with the correct options" do
      seed_brokers = "kafka://localhost:9092"
      connect_timeout = "10s"

      ConnectionPool::Wrapper.new do |wrapper|
        wrapper.with do |producer|
          configure_client(producer)
          expect(producer.config.deliver).to be(true)
          expect(producer.config.logger).to eq(logger)
          expect(producer.config.wait_on_queue_full).to be(false)
          expect(producer.config.kafka).to include(
            "bootstrap.servers": seed_brokers.sub("kafka://", ""),
            "producer.connect.timeout.ms": connect_timeout.delete_suffix("s").to_i * 1000
          )
        end
      end
    end
  end
end
