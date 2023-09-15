# frozen_string_literal: true

require "anyway_config"
require "sbmt/waterdrop"
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
loader.ignore("#{File.expand_path("../", __dir__)}/generators")

loader.do_not_eager_load("#{__dir__}/kafka_producer/instrumentation/open_telemetry_loader.rb")
loader.do_not_eager_load("#{__dir__}/kafka_producer/instrumentation/open_telemetry_tracer.rb")

# completely ignore testing helpers
# because testing.rb just requires some files and does not contain any constants (e.g. Testing) which Zeitwerk expects
loader.ignore("#{__dir__}/kafka_producer/testing.rb")
loader.ignore("#{__dir__}/kafka_producer/testing")

loader.setup
loader.eager_load
