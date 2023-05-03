# frozen_string_literal: true

describe Sbmt::KafkaProducer::OutboxProducer do
  subject(:outbox_producer) { described_class.new(client: client, topic: topic) }

  let(:client) { instance_double(Sbmt::WaterDrop::Producer) }
  let(:topic) { "test_topic" }
  let(:payload) { {message: "payload"} }
  let(:outbox_item) { double("OutboxItem", options: {partition: 0}) }

  before do
    allow(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:default_client).and_return(client)
  end

  describe "#call" do
    it "calls sync_publish with payload and outbox_item options" do
      expect_any_instance_of(described_class).to receive(:sync_publish).with(payload, partition: 0)
      outbox_producer.call(outbox_item, payload)
    end
  end

  describe "#sync_publish" do
    it "calls client.produce_sync with payload and merged options" do
      expect(client).to receive(:produce_sync).with(payload: payload, topic: topic, partition: 0)
      outbox_producer.sync_publish(payload, partition: 0)
    end
  end

  describe "dependencies" do
    it "sets client to the default_client if not specified" do
      allow(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:default_client).and_return(client)
      outbox_producer = described_class.new(topic: topic)

      expect(outbox_producer.client).to eq(client)
    end

    it "sets topic to the specified value" do
      outbox_producer = described_class.new(client: client, topic: topic)

      expect(outbox_producer.topic).to eq(topic)
    end
  end
end
