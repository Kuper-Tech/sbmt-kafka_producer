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

    it "successfully loads config and translates to kafka options" do
      with_env(
        "KAFKA_PRODUCER_KAFKA_SERVERS" => servers
      ) do
        expect(config.servers).to eq(servers)
        expect(config.to_kafka_options)
          .to eq("bootstrap.servers": servers)
      end
    end
  end
end
