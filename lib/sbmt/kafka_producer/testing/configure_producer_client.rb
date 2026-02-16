# frozen_string_literal: true

class FakeWaterDropClient
  Report = Struct.new(:topic_name, :partition, :offset)

  def produce_sync(*)
    Report.new("fake_topic", 0, 0)
  end

  def produce_async(*)
    # no op
  end
end

Sbmt::KafkaProducer::KafkaClientFactory.singleton_class.prepend(
  Module.new do
    def default_client
      @default_client ||= FakeWaterDropClient.new
    end

    def build(*)
      @default_client ||= FakeWaterDropClient.new
    end
  end
)
