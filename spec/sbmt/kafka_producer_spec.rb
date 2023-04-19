# frozen_string_literal: true

RSpec.describe Sbmt::KafkaProducer do
  it "has a version number" do
    expect(Sbmt::KafkaProducer::VERSION).not_to be_nil
  end
end
