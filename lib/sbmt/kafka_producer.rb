# frozen_string_literal: true

require "zeitwerk"
require "connection_pool"

module Sbmt
  module KafkaProducer
    class << self
      def deliver
        true
      end

      def kafka
        {}
      end
    end

    class Error < StandardError; end
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, ".."))
loader.tag = "sbmt-kafka_producer"
# Do not load vendors instrumentation components. Those need to be required manually if needed
loader.ignore("#{__dir__}/kafka_producer/version.rb")
loader.setup
loader.eager_load
