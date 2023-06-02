# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    class Railtie < Rails::Railtie
      initializer "sbmt_kafka_producer_yabeda.configure_rails_initialization" do
        YabedaConfigurer.configure
      end
    end
  end
end
