# frozen_string_literal: true

require "rails_helper"

describe Sbmt::KafkaProducer::BaseProducer do
  let(:client) { instance_double(Sbmt::WaterDrop::Producer) }
  let(:topic) { "test_topic" }
  let(:payload) { {message: "payload"} }

  before do
    allow(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:default_client).and_return(client)
  end

  describe "#publish" do
    it "calls client.produce_sync with payload and options" do
      expect(client).to receive(:produce_sync).with(payload: payload, topic: topic)
      described_class.new(client: client, topic: topic).publish(payload)
    end

    it "merges the provided options with topic and calls client.produce_sync" do
      options = {partition: 0}

      expect(client).to receive(:produce_sync).with(payload: payload, topic: topic, partition: 0)
      described_class.new(client: client, topic: topic).publish(payload, options)
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
