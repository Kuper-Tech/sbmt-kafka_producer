# frozen_string_literal: true

class FakeWaterDropClient
  def produce_sync(*)
    # no op
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
