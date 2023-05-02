# frozen_string_literal: true

describe Sbmt::KafkaProducer::BaseProducer do
  let(:producer) { described_class.new(client: client, topic: topic) }
  let(:client) { instance_double(Sbmt::WaterDrop::Producer) }
  let(:topic) { "test_topic" }
  let(:payload) { {message: "payload"} }

  before do
    allow(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:default_client).and_return(client)
  end

  describe "#publish" do
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
        expect(producer.publish(payload, options)).to be(true)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_sync).and_raise(Sbmt::WaterDrop::Errors::ProduceError)
      end

      it "logs the error and returns false" do
        expect(producer).to receive(:log_error).once
        expect(producer.publish(payload, options)).to be(false)
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

  describe "#ignore_kafka_errors?" do
    context "when IGNORE_KAFKA_ERRORS is set to true" do
      before { stub_const("#{described_class}::IGNORE_KAFKA_ERRORS", true) }

      it "returns true" do
        expect(producer.send(:ignore_kafka_errors?)).to be(true)
      end
    end

    context "when IGNORE_KAFKA_ERRORS is set to false" do
      before { stub_const("#{described_class}::IGNORE_KAFKA_ERRORS", false) }

      it "returns false" do
        expect(producer.send(:ignore_kafka_errors?)).to be(false)
      end
    end
  end
end
