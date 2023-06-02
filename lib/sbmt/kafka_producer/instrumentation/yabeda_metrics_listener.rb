# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Instrumentation
      class YabedaMetricsListener
        DEFAULT_CLIENT = {client: "sbmt-waterdrop"}.freeze
        def on_statistics_emitted(event)
          # https://github.com/confluentinc/librdkafka/blob/master/STATISTICS.md
          stats = event.payload[:statistics]
          broker_stats = stats["brokers"]

          report_broker_stats(broker_stats)
        end

        def on_error_occurred(event)
          caller = event[:caller]
          tags = {topic: event[:topic]}.merge!(DEFAULT_CLIENT) if event.payload.include?(:topic)

          case event[:type]
          when "message.produce_sync", "message.produce_async"
            Yabeda.kafka_producer.produce_errors
              .increment(produce_base_tags(caller))
          when "librdkafka.dispatch_error"
            Yabeda.kafka_producer.deliver_errors
              .increment(tags)
          end
        end

        %i[produced_sync produced_async].each do |event_scope|
          define_method("on_message_#{event_scope}") do |event|
            Yabeda.kafka_producer.produced_messages
              .increment(produce_base_tags(event))

            Yabeda.kafka_producer.message_size
              .measure(produce_base_tags(event), event[:message].to_s.bytesize)

            Yabeda.kafka_producer.deliver_latency
              .measure(produce_base_tags(event), event[:time])
          end
        end

        def on_message_buffered(event)
          Yabeda.kafka_producer.buffer_size
            .measure(DEFAULT_CLIENT, event[:buffer].size)
        end

        def on_message_acknowledged(event)
          tag = {topic: event[:topic]}.merge!(DEFAULT_CLIENT)

          Yabeda.kafka_producer.deliver_messages
            .increment(tag)
        end

        private

        def produce_base_tags(event)
          {
            client: DEFAULT_CLIENT[:client],
            topic: event[:message][:topic]
          }
        end

        def report_broker_stats(brokers)
          brokers.each_value do |broker_statistics|
            # Skip bootstrap nodes
            next if broker_statistics["nodeid"] == -1

            broker_tags = {
              client: DEFAULT_CLIENT[:client],
              broker: broker_statistics["nodename"]
            }

            Yabeda.kafka_api.calls
              .increment(broker_tags, by: broker_statistics["tx"])
            Yabeda.kafka_api.latency
              .measure(broker_tags, broker_statistics["rtt"]["avg"])
            Yabeda.kafka_api.request_size
              .measure(broker_tags, broker_statistics["txbytes"])
            Yabeda.kafka_api.response_size
              .measure(broker_tags, broker_statistics["rxbytes"])
            Yabeda.kafka_api.errors
              .increment(broker_tags, by: broker_statistics["txerrs"] + broker_statistics["rxerrs"])
          end
        end
      end
    end
  end
end
