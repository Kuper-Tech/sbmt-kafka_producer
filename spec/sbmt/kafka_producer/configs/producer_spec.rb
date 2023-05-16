# frozen_string_literal: true

describe Sbmt::KafkaProducer::Configs::Producer, type: :config do
  context "when app initialized" do
    let(:default_env) {
      {
        "KAFKA_PRODUCER_AUTH__KIND" => "sasl_plaintext",
        "KAFKA_PRODUCER_AUTH__SASL_USERNAME" => "username",
        "KAFKA_PRODUCER_AUTH__SASL_PASSWORD" => "password",
        "KAFKA_PRODUCER_AUTH__SASL_MECHANISM" => "PLAIN",

        "KAFKA_PRODUCER_KAFKA__SERVERS" => "server1:9092,server2:9092"
      }
    }
    let(:config) { described_class.new }

    it "properly merges kafka options" do
      with_env(default_env) do
        expect(config.to_kafka_options)
          .to eq(
            "bootstrap.servers": "server1:9092,server2:9092",
            "security.protocol": "sasl_plaintext",
            "sasl.mechanism": "PLAIN",
            "sasl.password": "password",
            "sasl.username": "username",
            # loaded from kafka_producer.yml
            "message.send.max.retries": 2,
            "request.required.acks": -1,
            "request.timeout.ms": 1000.0,
            "retry.backoff.ms": 1000.0,
            "socket.connection.setup.timeout.ms": 1000.0
          )
      end
    end
  end
end
