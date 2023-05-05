# frozen_string_literal: true

describe Sbmt::KafkaProducer::BaseProducer do
  let(:producer) { described_class.new(client: client, topic: topic) }
  let(:client) { instance_double(Sbmt::WaterDrop::Producer) }
  let(:topic) { "test_topic" }
  let(:payload) { {message: "payload"} }

  before do
    allow(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:default_client).and_return(client)
  end

  describe "#sync_publish" do
    let(:options) { {seed_brokers: "kafka://kafka:9092"} }

    context "when payload is successfully delivered" do
      before do
        allow(client).to receive(:produce_sync).with(
          payload: payload,
          topic: "test_topic",
          seed_brokers: "kafka://kafka:9092"
        ).and_return(true)
      end

      it "produces the payload via the client and returns true" do
        expect(producer.sync_publish(payload, options)).to be(true)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_sync).and_raise(Sbmt::WaterDrop::Errors::ProduceError)
      end

      it "logs the error and returns false" do
        expect(producer).to receive(:log_error).once
        expect(producer.sync_publish(payload, options)).to be(false)
      end
    end
  end

  describe "#async_publish" do
    let(:options) { {seed_brokers: "kafka://kafka:9092"} }

    context "when payload is successfully delivered" do
      before do
        allow(client).to receive(:produce_async).with(
          payload: payload,
          topic: "test_topic",
          seed_brokers: "kafka://kafka:9092"
        ).and_return(true)
      end

      it "produces the payload via the client and returns true" do
        expect(producer.async_publish(payload, options)).to be(true)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_async).and_raise(Sbmt::WaterDrop::Errors::ProduceError)
      end

      it "logs the error and returns false" do
        expect(producer).to receive(:log_error).once
        expect(producer.async_publish(payload, options)).to be(false)
      end
    end
  end

  describe "#initialize" do
    it "sets the client to the default client if no client is provided" do
      producer = described_class.new(topic: topic)
      expect(producer.client).to eq(client)
    end

    it "sets the topic" do
      producer = described_class.new(client: client, topic: topic)

      expect(producer.topic).to eq(topic)
    end
  end
end
