# frozen_string_literal: true

require_relative "helpers"

module KafkaProducer
  module Generators
    class Base < Rails::Generators::Base
      include Helpers::Config
      include Helpers::Producer
    end

    class NamedBase < Rails::Generators::NamedBase
      include Helpers::Config
      include Helpers::Producer
    end
  end
end
