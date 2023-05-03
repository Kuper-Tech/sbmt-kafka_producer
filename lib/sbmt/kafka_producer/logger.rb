# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class Logger
      delegate :logger, to: :Rails

      %i[
        debug
        info
        warn
        error
        fatal
      ].each do |log_level|
        define_method log_level do |*args|
          logger.send(log_level, *args)
        end
      end
    end
  end
end
