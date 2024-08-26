# frozen_string_literal: true

describe Sbmt::KafkaProducer::KafkaClientFactory do
  describe ".default_client" do
    it "returns a ConnectionPool::Wrapper with a WaterDrop::Producer inside" do
      expect(described_class.default_client.with { |producer| producer }).to be_instance_of(WaterDrop::Producer)
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
        expect(described_class.build(kafka_config).with { |producer| producer }).to be_instance_of(WaterDrop::Producer)
      end

      it "always returns the same client" do
        client = described_class.build(kafka_config)
        expect(described_class.build(kafka_config).object_id).to eq client.object_id
      end
    end
  end

  describe ".configure_client" do
    it "configures the client with the correct options" do
      # rubocop:disable Style/HashSyntax
      kafka_opts = {
        message_timeout: 54000,
        "queue.buffering.max.messages": 14,
        "ack_timeout" => 1555,
        "queue.buffering.max.ms" => 1345
      }
      # rubocop:enable Style/HashSyntax

      described_class.build(kafka_opts).with do |producer|
        expect(producer.config.deliver).to be(true)
        expect(producer.config.logger).to be_instance_of(Sbmt::KafkaProducer::Logger)
        expect(producer.config.wait_on_queue_full).to be(true)
        expect(producer.config.max_wait_timeout).to eq(60000)
        expect(producer.config.kafka).to include(
          "bootstrap.servers": "kafka:9092",
          "message.timeout.ms": 54000,
          "request.timeout.ms": 1555,
          "queue.buffering.max.ms": 1345
        )
      end
    end
  end
end
