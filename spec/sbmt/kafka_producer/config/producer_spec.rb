# frozen_string_literal: true

describe Sbmt::KafkaProducer::Config::Producer, type: :config do
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
    let(:kafka_config_defaults) do
      {
        "socket.connection.setup.timeout.ms": 1000,
        "request.timeout.ms": 1000,
        "request.required.acks": -1,
        "message.send.max.retries": 2,
        "retry.backoff.ms": 1000,
        "message.timeout.ms": 55000
      }
    end

    it "properly merges kafka options" do
      with_env(default_env) do
        expect(config.to_kafka_options)
          .to eq(kafka_config_defaults.merge(
            "bootstrap.servers": "server1:9092,server2:9092",
            "security.protocol": "sasl_plaintext",
            "sasl.mechanism": "PLAIN",
            "sasl.password": "password",
            "sasl.username": "username",
            # loaded from kafka_producer.yml
            "message.send.max.retries": 2,
            "request.required.acks": -1,
            "request.timeout.ms": 1000,
            "retry.backoff.ms": 1000,
            "socket.connection.setup.timeout.ms": 2000,
            # arbitrary parameters for section kafka_config file kafka_producer.yml
            "queue.buffering.max.messages": 1,
            "queue.buffering.max.ms": 10000
          ))
      end
    end

    it "has correct defaults" do
      with_env(default_env) do
        expect(config.logger_class).to eq("::Sbmt::KafkaProducer::Logger")
        expect(config.metrics_listener_class).to eq("::Sbmt::KafkaProducer::Instrumentation::YabedaMetricsListener")
      end
    end

    context "when kafka_config options overwrite auth params" do
      let(:ca_cert) { OpenSSL::PKey::RSA.new(2048).to_s }
      let(:default_env) do
        super().merge(
          "KAFKA_PRODUCER_KAFKA__KAFKA_CONFIG__SECURITY.PROTOCOL" => "SASL_SSL",
          "KAFKA_PRODUCER_KAFKA__KAFKA_CONFIG__SASL.MECHANISM" => "SCRAM-SHA-512",
          "KAFKA_PRODUCER_KAFKA__KAFKA_CONFIG__SSL.CA.PEM" => ca_cert
        )
      end

      it "properly merges kafka options uses auth params from low-level config" do
        with_env(default_env) do
          expect(config.to_kafka_options)
            .to eq(kafka_config_defaults.merge(
              "bootstrap.servers": "server1:9092,server2:9092",
              "security.protocol": "SASL_SSL",
              "sasl.mechanism": "SCRAM-SHA-512",
              "ssl.ca.pem": ca_cert,
              "sasl.password": "password",
              "sasl.username": "username",
              # loaded from kafka_producer.yml
              "message.send.max.retries": 2,
              "request.required.acks": -1,
              "request.timeout.ms": 1000,
              "retry.backoff.ms": 1000,
              "socket.connection.setup.timeout.ms": 2000,
              # arbitrary parameters for section kafka_config file kafka_producer.yml
              "queue.buffering.max.messages": 1,
              "queue.buffering.max.ms": 10000
            ))
        end
      end
    end
  end
end
