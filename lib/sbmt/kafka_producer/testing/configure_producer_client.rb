# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    allow(Sbmt::KafkaProducer::KafkaClientFactory)
      .to receive(:default_client)
      .and_return(double(Sbmt::WaterDrop::Producer, {produce_sync: true, produce_async: true}))

    allow(Sbmt::KafkaProducer::KafkaClientFactory)
      .to receive(:build)
      .and_return(double(Sbmt::WaterDrop::Producer, {produce_sync: true, produce_async: true}))
  end
end
