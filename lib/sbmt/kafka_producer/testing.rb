# frozen_string_literal: true

require "rspec"

Dir["#{__dir__}/testing/*.rb"].sort.each { |f| require f }
