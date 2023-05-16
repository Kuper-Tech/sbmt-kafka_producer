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
    let(:kafka_config) {
      {"max_retries" => 2,
       "required_acks" => -1,
       "ack_timeout" => 1,
       "retry_backoff" => 1,
       "connect_timeout" => 1}
    }

    before do
      stub_const("ENV", {"KAFKA_PRODUCER_KAFKA_SERVERS" => "server1:9092,server2:9092"})
      allow(Sbmt::KafkaProducer::Configs::Producer).to receive(:to_kafka_options).and_return(config.kafka_config = kafka_config)
    end

    it "successfully loads config and translates to kafka options" do
      expect(config.servers).to eq("server1:9092,server2:9092")
      expect(config.to_kafka_options)
        .to eq(
          "bootstrap.servers": servers,
          "message.send.max.retries": 2,
          "request.required.acks": -1,
          "request.timeout.ms": 1000.0,
          "retry.backoff.ms": 1000.0,
          "socket.connection.setup.timeout.ms": 1000.0
        )
    end
  end
end
