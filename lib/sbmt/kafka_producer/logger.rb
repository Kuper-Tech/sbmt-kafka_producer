# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class Logger
      delegate :logger, to: :Rails
    end
  end
end
