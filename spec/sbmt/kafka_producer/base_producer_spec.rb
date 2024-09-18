# frozen_string_literal: true

class TestWrapError < WaterDrop::Errors::ProduceError
  attr_reader :cause

  def initialize(message, cause)
    super(message)
    @cause = cause
  end
end

describe Sbmt::KafkaProducer::BaseProducer do
  let(:producer) { described_class.new(client: client, topic: topic) }
  let(:client) { instance_double(WaterDrop::Producer) }
  let(:topic) { "test_topic" }
  let(:payload) { {message: "payload"} }
  let(:error) { WaterDrop::Errors::ProduceError }
  let(:delivery_report) do
    instance_double(Rdkafka::Producer::DeliveryReport,
      error: nil,
      label: nil,
      offset: 0,
      partition: 0,
      topic_name: "my_topic")
  end
  let(:delivery_handle) do
    instance_double(Rdkafka::Producer::DeliveryHandle,
      label: nil,
      wait: delivery_report)
  end
  let(:logger) { ActiveSupport::TaggedLogging.new(Logger.new($stdout)) }
  let(:options) { {seed_brokers: "kafka://kafka:9092"} }

  before do
    allow(Sbmt::KafkaProducer::KafkaClientFactory).to receive(:default_client).and_return(client)
    allow(Sbmt::KafkaProducer).to receive(:logger).and_return(logger)
  end

  describe "#sync_publish" do
    context "when payload is successfully delivered" do
      before do
        allow(client).to receive(:produce_sync).with(
          payload: payload,
          topic: "test_topic",
          seed_brokers: "kafka://kafka:9092"
        ).and_return(delivery_report, 0.1)
      end

      it "produces the payload via the client and returns true" do
        expect(producer.sync_publish(payload, options)).to be(true)
      end

      it "logs the success message with correct tags" do
        expect(logger).to receive(:tagged).with(hash_including(
          kafka: hash_including(
            topic: "my_topic",
            partition: 0,
            offset: 0,
            produce_duration_ms: kind_of(Numeric)
          )
        )).and_yield

        expect(logger).to receive(:info).with("Message has been successfully sent to Kafka")

        producer.sync_publish(payload, options)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_sync).and_raise(error)
      end

      it "logs the error and returns false" do
        expect(producer).to receive(:log_error).once
        expect(producer.sync_publish(payload, options)).to be(false)
      end

      context "when multiple exception" do
        before do
          allow_any_instance_of(described_class).to receive(:ignore_kafka_errors?).and_return(false)
        end

        let(:error) do
          cause = StandardError.new("Second Exception")
          TestWrapError.new("First Exception", cause)
        end

        it "raises an error" do
          expect(logger).to receive(:tagged).with(include(:stacktrace)).and_yield
          expect(logger).to receive(:error).with(/KAFKA ERROR: StandardError Second Exception. TestWrapError First Exception/)

          expect(producer.sync_publish(payload, options)).to be(false)
        end
      end
    end
  end

  describe "#sync_publish!" do
    context "when payload is successfully delivered" do
      before do
        allow(client).to receive(:produce_sync).with(
          payload: payload,
          topic: "test_topic",
          seed_brokers: "kafka://kafka:9092"
        ).and_return(delivery_report, 0.2)
      end

      it "produces the payload via the client and returns true" do
        expect(producer.sync_publish!(payload, options)).to be(true)
      end

      it "logs the success message with correct tags" do
        expect(logger).to receive(:tagged).with(hash_including(
          kafka: hash_including(
            topic: "my_topic",
            partition: 0,
            offset: 0,
            produce_duration_ms: kind_of(Numeric)
          )
        )).and_yield

        expect(logger).to receive(:info).with("Message has been successfully sent to Kafka")

        producer.sync_publish!(payload, options)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_sync).and_raise(error)
      end

      it "raises an error" do
        expect { producer.sync_publish!(payload, options) }.to raise_error(error)
      end
    end
  end

  describe "#async_publish" do
    context "when payload is successfully delivered" do
      before do
        allow(client).to receive(:produce_async).with(
          payload: payload,
          topic: "test_topic",
          seed_brokers: "kafka://kafka:9092"
        ).and_return(delivery_handle)
      end

      it "produces the payload via the client and returns true" do
        expect(producer.async_publish(payload, options)).to be(true)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_async).and_raise(error)
      end

      it "logs the error and returns false" do
        expect(producer).to receive(:log_error).once
        expect(producer.async_publish(payload, options)).to be(false)
      end

      context "when multiple exception" do
        before do
          allow_any_instance_of(described_class).to receive(:ignore_kafka_errors?).and_return(false)
        end

        let(:error) do
          cause = StandardError.new("Second Exception")
          TestWrapError.new("First Exception", cause)
        end

        it "raises an error" do
          expect(logger).to receive(:tagged).with(include(:stacktrace)).and_yield
          expect(logger).to receive(:error).with(/KAFKA ERROR: StandardError Second Exception. TestWrapError First Exception/)

          expect(producer.async_publish(payload, options)).to be(false)
        end
      end
    end
  end

  describe "#async_publish!" do
    context "when payload is successfully delivered" do
      before do
        allow(client).to receive(:produce_async).with(
          payload: payload,
          topic: "test_topic",
          seed_brokers: "kafka://kafka:9092"
        ).and_return(delivery_handle)
      end

      it "produces the payload via the client and returns true" do
        expect(producer.async_publish!(payload, options)).to be(true)
      end
    end

    context "when delivery fails with Kafka::DeliveryFailed" do
      before do
        allow(client).to receive(:produce_async).and_raise(error)
      end

      it "raises an error" do
        expect { producer.async_publish!(payload, options) }.to raise_error(error)
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
