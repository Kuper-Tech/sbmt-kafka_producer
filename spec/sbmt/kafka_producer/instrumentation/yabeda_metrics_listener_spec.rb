# frozen_string_literal: true

require "ostruct"

describe Sbmt::KafkaProducer::Instrumentation::YabedaMetricsListener do
  describe ".on_statistics_emitted" do
    let(:base_rdkafka_stats) {
      {
        "client_id" => "waterdrop",
        "brokers" => {
          "kafka:9092/1001" => {
            "name" => "kafka:9092/1001",
            "nodeid" => 1001,
            "nodename" => "kafka:9092",
            "tx_d" => 7,
            "txbytes" => 338,
            "txerrs_d" => 0,
            "rx" => 7,
            "rxbytes" => 827,
            "rxerrs_d" => 0,
            "rtt" => {
              "avg" => 1984
            }
          }
        }
      }.freeze
    }

    context "when only base data is available" do
      let(:event) do
        Karafka::Core::Monitoring::Event.new(
          "statistics.emitted",
          {statistics: base_rdkafka_stats}
        )
      end

      it "reports only broker metrics" do
        tags = {client: "waterdrop", broker: "kafka:9092"}
        expect {
          described_class.new.on_statistics_emitted(event)
        }.to measure_yabeda_histogram(Yabeda.kafka_api.latency).with_tags(tags)
          .and measure_yabeda_histogram(Yabeda.kafka_api.request_size).with_tags(tags)
          .and measure_yabeda_histogram(Yabeda.kafka_api.response_size).with_tags(tags)
          .and increment_yabeda_counter(Yabeda.kafka_api.calls).with_tags(tags)
          .and increment_yabeda_counter(Yabeda.kafka_api.errors).with_tags(tags)
      end
    end
  end

  describe ".on_error_occurred" do
    let(:topic) { OpenStruct.new({topic: "topic"}) }
    let(:tags) do
      {
        client: "waterdrop",
        topic: "topic"
      }
    end

    context "when error type is message.produce_sync" do
      let(:event) { Karafka::Core::Monitoring::Event.new("error.occurred", type: "message.produce_sync", message: topic) }

      it "increments producer error counter" do
        expect { described_class.new.on_error_occurred(event) }
          .to increment_yabeda_counter(Yabeda.kafka_producer.produce_errors)
          .with_tags(tags)
      end
    end

    context "when error type is message.produce_async" do
      let(:event) { Karafka::Core::Monitoring::Event.new("error.occurred", type: "message.produce_async", message: topic) }

      it "increments producer error counter" do
        expect { described_class.new.on_error_occurred(event) }
          .to increment_yabeda_counter(Yabeda.kafka_producer.produce_errors)
          .with_tags(tags)
      end
    end

    context "when error type is librdkafka.dispatch_error" do
      let(:event) { Karafka::Core::Monitoring::Event.new("error.occurred", topic: "topic", type: "librdkafka.dispatch_error") }

      tags = {client: "waterdrop", topic: "topic"}

      it "increments producer error counter" do
        expect { described_class.new.on_error_occurred(event) }
          .to increment_yabeda_counter(Yabeda.kafka_producer.deliver_errors)
          .with_tags(tags)
      end
    end
  end

  describe ".on_message_produced_sync" do
    let(:topic) { OpenStruct.new({topic: "topic"}) }
    let(:event) { Karafka::Core::Monitoring::Event.new("on_message_produced_sync", message: topic, time: 25) }

    tags = {client: "waterdrop", topic: "topic"}

    it "reports produced sync message metrics" do
      expect { described_class.new.on_message_produced_sync(event) }
        .to increment_yabeda_counter(Yabeda.kafka_producer.produced_messages).with_tags(tags)
        .and measure_yabeda_histogram(Yabeda.kafka_producer.message_size).with_tags(tags)
        .and measure_yabeda_histogram(Yabeda.kafka_producer.deliver_latency).with_tags(tags)
    end
  end

  describe ".on_message_produced_async" do
    let(:topic) { OpenStruct.new({topic: "topic"}) }
    let(:event) { Karafka::Core::Monitoring::Event.new("on_message_produced_async", message: topic, time: 25) }

    tags = {client: "waterdrop", topic: "topic"}

    it "reports produced async message metrics" do
      expect { described_class.new.on_message_produced_async(event) }
        .to increment_yabeda_counter(Yabeda.kafka_producer.produced_messages).with_tags(tags)
        .and measure_yabeda_histogram(Yabeda.kafka_producer.message_size).with_tags(tags)
        .and measure_yabeda_histogram(Yabeda.kafka_producer.deliver_latency).with_tags(tags)
    end
  end

  describe ".on_message_buffered" do
    let(:event) { Karafka::Core::Monitoring::Event.new("on_message_buffered", buffer: "buffer") }

    it "histogram produced buffer size metrics" do
      expect { described_class.new.on_message_buffered(event) }
        .to measure_yabeda_histogram(Yabeda.kafka_producer.buffer_size).with_tags({client: "waterdrop"})
    end
  end

  describe ".on_message_acknowledged" do
    let(:topic) { OpenStruct.new({topic: "topic"}) }
    let(:event) { Karafka::Core::Monitoring::Event.new("on_message_acknowledged", topic: "topic") }

    tags = {client: "waterdrop", topic: "topic"}

    it "increments produced acknowledged metrics" do
      expect { described_class.new.on_message_acknowledged(event) }
        .to increment_yabeda_counter(Yabeda.kafka_producer.deliver_messages).with_tags(tags)
    end
  end
end
