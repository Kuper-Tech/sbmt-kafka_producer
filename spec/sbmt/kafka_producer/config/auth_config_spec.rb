# frozen_string_literal: true

describe Sbmt::KafkaProducer::Config::Auth, type: :config do
  let(:config) { described_class.new }

  context "when no auth configured" do
    it "defaults to plaintext and properly translates to kafka options" do
      expect(config.kind).to eq("plaintext")
      expect(config.to_kafka_options).to eq("security.protocol": "plaintext")
    end
  end

  context "when sasl plaintext auth is used" do
    let(:config) {
      described_class.new(
        kind: "sasl_plaintext", sasl_mechanism: "PLAIN",
        sasl_username: "username", sasl_password: "password"
      )
    }

    it "loads valid config and properly translates to kafka options" do
      with_env(
        "KAFKA_PRODUCER_AUTH_KIND" => "sasl_plaintext",
        "KAFKA_PRODUCER_AUTH_SASL_USERNAME" => "username",
        "KAFKA_PRODUCER_AUTH_SASL_PASSWORD" => "password",
        "KAFKA_PRODUCER_AUTH_SASL_MECHANISM" => "PLAIN"
      ) do
        expect(config.kind).to eq("sasl_plaintext")
        expect(config.sasl_username).to eq("username")
        expect(config.sasl_password).to eq("password")
        expect(config.sasl_mechanism).to eq("PLAIN")
        expect(config.to_kafka_options)
          .to eq({
            "security.protocol": "sasl_plaintext",
            "sasl.password": "password",
            "sasl.username": "username",
            "sasl.mechanism": "PLAIN"
          })
      end
    end

    it "raises on empty username" do
      expect { described_class.new(kind: "sasl_plaintext").to_kafka_options }
        .to raise_error(/sasl_username is required/)
    end

    it "raises on empty password" do
      expect { described_class.new(kind: "sasl_plaintext", sasl_username: "username").to_kafka_options }
        .to raise_error(/sasl_password is required/)
    end

    it "sasl_mechanism defaults to SCRAM-SHA-512" do
      expect(described_class.new(kind: "sasl_plaintext",
        sasl_username: "username",
        sasl_password: "password").to_kafka_options)
        .to eq({
          "security.protocol": "sasl_plaintext",
          "sasl.password": "password",
          "sasl.username": "username",
          "sasl.mechanism": "SCRAM-SHA-512"
        })
    end
  end
end
