# frozen_string_literal: true

describe Sbmt::KafkaProducer::OutboxTransportFactory do
  let(:topic) { "test_topic" }
  let(:kafka_config) { {bootstrap_servers: ["localhost:9092"]} }

  describe ".build" do
    it "returns an instance of OutboxProducer" do
      expect(described_class.build(topic: topic, kafka: kafka_config)).to be_instance_of(Sbmt::KafkaProducer::OutboxProducer)
    end

    it "passes the topic and a client to OutboxProducer" do
      client = instance_double(Sbmt::WaterDrop::Producer)

      expect(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:build).with(kafka_config).and_return(client)
      expect(Sbmt::KafkaProducer::OutboxProducer).to receive(:new).with(topic: topic, client: client)
      described_class.build(topic: topic, kafka: kafka_config)
    end
  end
end
