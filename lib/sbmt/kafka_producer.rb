# frozen_string_literal: true

require "anyway_config"
require "connection_pool"
require "dry-initializer"
require "dry/types"
require "dry-struct"
require "rails/railtie"
require "sentry-ruby"
require "yabeda"
require "zeitwerk"

module Sbmt
  module KafkaProducer
    class << self
      def logger
        @logger ||= Logger.new
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
