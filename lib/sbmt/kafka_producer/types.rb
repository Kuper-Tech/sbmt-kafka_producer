# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Types
      include Dry.Types

      ConfigAttrs = Dry::Types["hash"].constructor { |hsh| hsh.deep_symbolize_keys }
      ConfigProducer = Types.Constructor(Config::Producer)
    end
  end
end
