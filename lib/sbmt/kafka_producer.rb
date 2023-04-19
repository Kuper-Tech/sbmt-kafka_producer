# frozen_string_literal: true

require "zeitwerk"

module Sbmt
  module KafkaProducer
    class Error < StandardError; end
    # Your code goes here...
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, ".."))
loader.tag = "sbmt-kafka_producer"
# Do not load vendors instrumentation components. Those need to be required manually if needed
loader.ignore("#{__dir__}/kafka_producer/version.rb")
loader.setup
loader.eager_load
