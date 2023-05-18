# frozen_string_literal: true

describe Sbmt::KafkaProducer::Configs::Kafka, type: :config do
  let(:config) { described_class.new }

  context "with servers validation" do
    it "raises error if servers are not set" do
      expect { config }.to raise_error(/are missing or empty: servers/)
    end

    it "raises error if servers have unexpected format" do
      with_env(
        "KAFKA_PRODUCER_KAFKA_SERVERS" => "kafka://server:9092"
      ) do
        expect { config }.to raise_error(/invalid servers:/)
      end
    end
  end

  context "when servers are properly set" do
    let(:servers) { "server1:9092,server2:9092" }
    let(:max_retries) { 2 }
    let(:required_acks) { -1 }
    let(:ack_timeout) { 1000.0 }
    let(:retry_backoff) { 1000.0 }
    let(:connect_timeout) { 1000.0 }

    before do
      stub_const("ENV",
        {
          "KAFKA_PRODUCER_KAFKA_SERVERS" => "server1:9092,server2:9092",
          "KAFKA_PRODUCER_KAFKA_MAX_RETRIES" => 2,
          "KAFKA_PRODUCER_KAFKA_REQUIRED_ACKS" => -1,
          "KAFKA_PRODUCER_KAFKA_ACK_TIMEOUT" => 1,
          "KAFKA_PRODUCER_KAFKA_RETRY_BACKOFF" => 1,
          "KAFKA_PRODUCER_KAFKA_CONNECT_TIMEOUT" => 1
        })
    end

    it "successfully loads config and translates to kafka options" do
      expect(config.servers).to eq("server1:9092,server2:9092")
      expect(config.to_kafka_options)
        .to eq(
          "bootstrap.servers": servers,
          "message.send.max.retries": max_retries,
          "request.required.acks": required_acks,
          "request.timeout.ms": ack_timeout,
          "retry.backoff.ms": retry_backoff,
          "socket.connection.setup.timeout.ms": connect_timeout
        )
    end
  end
end
