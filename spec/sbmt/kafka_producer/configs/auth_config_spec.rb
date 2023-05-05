# frozen_string_literal: true

describe Sbmt::KafkaProducer::Configs::Auth, type: :config do
  let(:config) { described_class.new }

  context "when no auth configured" do
    it "defaults to plaintext and properly translates to kafka options" do
      expect(config.kind).to eq("plaintext")
      expect(config.to_kafka_options).to eq("security.protocol": "plaintext")
    end
  end

  context "when sasl plaintext auth is used" do
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
      with_env(
        "KAFKA_PRODUCER_AUTH_KIND" => "sasl_plaintext",
        "KAFKA_PRODUCER_AUTH_SASL_USERNAME" => ""
      ) do
        expect { config }.to raise_error(/sasl_username is required/)
        expect { config.to_kafka_options }.to raise_error(/sasl_username is required/)
      end
    end

    it "raises on empty password" do
      with_env(
        "KAFKA_PRODUCER_AUTH_KIND" => "sasl_plaintext",
        "KAFKA_PRODUCER_AUTH_SASL_USERNAME" => "username",
        "KAFKA_PRODUCER_AUTH_SASL_PASSWORD" => ""
      ) do
        expect { config }.to raise_error(/sasl_password is required/)
        expect { config.to_kafka_options }.to raise_error(/sasl_password is required/)
      end
    end

    it "raises on empty mechanism" do
      with_env(
        "KAFKA_PRODUCER_AUTH_KIND" => "sasl_plaintext",
        "KAFKA_PRODUCER_AUTH_SASL_USERNAME" => "username",
        "KAFKA_PRODUCER_AUTH_SASL_PASSWORD" => "password",
        "KAFKA_PRODUCER_AUTH_SASL_MECHANISM" => ""
      ) do
        expect { config }.to raise_error(/sasl_mechanism is required/)
        expect { config.to_kafka_options }.to raise_error(/sasl_mechanism is required/)
      end
    end

    it "raises on unsupported mechanism" do
      with_env(
        "KAFKA_PRODUCER_AUTH_KIND" => "sasl_plaintext",
        "KAFKA_PRODUCER_AUTH_SASL_USERNAME" => "username",
        "KAFKA_PRODUCER_AUTH_SASL_PASSWORD" => "password",
        "KAFKA_PRODUCER_AUTH_SASL_MECHANISM" => "mechanism"
      ) do
        expect { config }.to raise_error(/invalid sasl_mechanism/)
        expect { config.to_kafka_options }.to raise_error(/invalid sasl_mechanism/)
      end
    end
  end
end
