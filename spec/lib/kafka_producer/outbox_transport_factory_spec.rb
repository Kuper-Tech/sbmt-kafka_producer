# frozen_string_literal: true

describe "Sbmt::KafkaProducer::OutboxTransportFactory" do
  subject(:producer) { Sbmt::KafkaProducer::OutboxTransportFactory }

  describe ".build" do
    context "when kafka is empty" do
      it "returns default client" do
        expect(producer.build(kafka: {})).to eq(producer.default_client)
      end
    end

    context "when kafka is not empty" do
      let(:kafka) { {bootstrap_servers: "localhost:9092"} }

      it "returns a new connection pool with Sbmt::KafkaProducer::Producer instance" do
        expect(producer.build(kafka: kafka)).to be_a(ConnectionPool)
        expect(producer.build(kafka: kafka).with { |producer| producer }).to be_a(Sbmt::WaterDrop::Producer)
      end
    end
  end

  describe ".default_client" do
    it "returns a new connection pool with Sbmt::KafkaProducer::Producer instance" do
      expect(producer.default_client).to be_a(ConnectionPool)
      expect(producer.default_client.with { |producer| producer }).to be_a(Sbmt::WaterDrop::Producer)
    end
  end

  describe ".setup" do
    let(:kafka_options) { {bootstrap_servers: "localhost:9092"} }

    context "when kafka options are provided" do
      it "sets up kafka options for the given config" do
        connection_pool = ConnectionPool.new do
          Sbmt::WaterDrop::Producer.new do |config|
            producer.setup(config, kafka: kafka_options)
          end
        end

        connection_pool.with do |producer|
          expect(producer.config.deliver).to eq(Sbmt::KafkaProducer.deliver)
          expect(producer.config.kafka.slice(:bootstrap_servers)).to eq(Sbmt::KafkaProducer.kafka.merge(kafka_options))
        end
      end
    end

    context "when no kafka options are provided" do
      it "sets up default kafka options for the given config" do
        connection_pool = ConnectionPool.new do
          Sbmt::WaterDrop::Producer.new do |config|
            producer.setup(config)
          end
        end

        connection_pool.with do |producer|
          expect(producer.config.deliver).to eq(Sbmt::KafkaProducer.deliver)
          expect(producer.config.kafka.slice(:bootstrap_servers)).to eq(Sbmt::KafkaProducer.kafka)
        end
      end
    end
  end
end
