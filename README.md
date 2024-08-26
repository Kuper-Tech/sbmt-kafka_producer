[![Gem Version](https://badge.fury.io/rb/sbmt-kafka_producer.svg)](https://badge.fury.io/rb/sbmt-kafka_producer)
[![Build Status](https://github.com/Kuper-Tech/sbmt-kafka_producer/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/Kuper-Tech/sbmt-kafka_producer/actions?query=branch%3Amaster)

# Sbmt-KafkaProducer

This gem is used to produce Kafka messages. It is a wrapper over the [waterdrop](https://github.com/karafka/waterdrop) gem, and it is recommended for use as a transport with the [sbmt-outbox](https://github.com/Kuper-Tech/sbmt-outbox) gem.

## Installation

Add this line to your app's Gemfile:

```ruby
gem "sbmt-kafka_producer"
```

And then execute:

```bash
bundle install
```

## Demo

Learn how to use this gem and how it works with Ruby on Rails at here https://github.com/Kuper-Tech/outbox-example-apps

## Auto configuration

We recommend going through the configuration and file creation process using the following Rails generators. Each generator can be run by using the `--help` option to learn more about the available arguments.

### Initial configuration

If you plug the gem into your application for the first time, you can generate the initial configuration:

```shell
rails g kafka_producer:install
```

As a result, the `config/kafka_producer.yml` file will be created.

### Producer class

A producer class can be generated with the following command:

```shell
rails g kafka_producer:producer MaybeNamespaced::Name sync topic
```

As the result, a sync producer will be created.

### Outbox producer

To generate an Outbox producer for use with Gem [sbmt-Outbox](https://github.com/Kuper-Tech/sbmt-outbox), run the following command:

```shell
rails g kafka_producer:outbox_producer SomeOutboxItem
```

## Manual configuration

The `config/kafka_producer.yml` file is the main configuration for this gem.

```yaml
default: &default
  deliver: true
  ignore_kafka_error: true
  # see more options at https://github.com/karafka/waterdrop/blob/master/lib/waterdrop/config.rb
  wait_on_queue_full: true
  max_payload_size: 1000012
  max_wait_timeout_ms: 60000
  auth:
    kind: plaintext
  kafka:
    servers: "kafka:9092" # required
    max_retries: 2 # optional, default: 2
    required_acks: -1 # optional, default: -1
    ack_timeout: 1000 # in milliseconds, optional, default: 1000
    retry_backoff: 1000 # in milliseconds, optional, default: 1000
    connect_timeout: 2000 # in milliseconds, optional, default: 2000
    message_timeout: 55000 # in milliseconds, optional, default: 55000
    kafka_config: # low-level custom Kafka options
      queue.buffering.max.messages: 1
      queue.buffering.max.ms: 10000

development:
  <<: *default

test:
  <<: *default
  deliver: false
  wait_on_queue_full: false

production:
  <<: *default
```

### `auth` config section

The gem supports 2 variants: plaintext (default) and SASL-plaintext

SASL-plaintext:

```yaml
auth:
  kind: sasl_plaintext
  sasl_username: user
  sasl_password: pwd
  sasl_mechanism: SCRAM-SHA-512
```

### `kafka` config section

The `servers` key is required and should be in rdkafka format: without `kafka://` prefix, for example: `srv1:port1,srv2:port2,...`.

The `kafka_config` section may contain any [rdkafka option](https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md)

### Producer class

To create a producer that will be responsible for sending messages to Kafka, copy the following code:

```ruby
# app/producers/some_producer.rb
class SomeProducer < Sbmt::KafkaProducer::BaseProducer
  option :topic, default: -> { "topic" }

  def publish(payload, **options)
    sync_publish(payload, options)
    # async_publish(payload, options)
  end
end
```

### Outbox producer config

Add the following lines to your `config/outbox.yml` file in the `transports` section:

```yaml
outbox_items:
  some_outbox_item:
    transports:
      sbmt/kafka_producer:
        topic: 'topic'
        kafka: # optional kafka options
          required_acks: -1
```

## Usage

To send a message to a Kafka topic, execute the following command:

```ruby
SomeProducer.new.publish(payload, key: "123", headers: {"some-header" => "some-value"})
```

## Metrics

The gem collects base producing metrics using [Yabeda](https://github.com/yabeda-rb/yabeda). See metrics at [YabedaConfigurer](./lib/sbmt/kafka_producer/yabeda_configurer.rb).

## Testing

To stub a producer request to real Kafka broker, you can use a fake class. To do this, please add `require "sbmt/kafka_producer/testing"` to the `spec/rails_helper.rb`.

## Development

Install [dip](https://github.com/bibendi/dip).

And run:

```shell
dip provision
dip rspec
```
