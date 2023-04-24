# frozen_string_literal: true

describe "Sbmt::KafkaProducer::BaseProducer" do
  subject(:base_producer) { described_class.new(topic: topic, kafka: kafka) }

  let(:topic) { "test-topic" }
  let(:payload) { {key: "value"} }
  let(:kafka) { {host: "localhost", port: 9092} }

  describe "#initialize" do
    it "initializes a new BaseProducer instance with given topic and kafka options" do
      expect(base_producer.instance_variable_get(:@topic)).to eq topic
      expect(base_producer.instance_variable_get(:@pool)).to be_an_instance_of(ConnectionPool)
    end
  end

  describe "#call" do
    let(:client) { instance_double(Sbmt::WaterDrop::Producer) }
    let(:pool) { instance_double(ConnectionPool) }

    before do
      allow(ConnectionPool).to receive(:new).and_return(pool)
      allow(pool).to receive(:with).and_yield(client)
      allow(client).to receive(:produce_sync)
    end

    it "sends a message to Kafka using the producer client" do
      base_producer.call("item", payload)

      expect(client).to have_received(:produce_sync).with(topic: topic, item: "item", payload: payload)
    end
  end
end
