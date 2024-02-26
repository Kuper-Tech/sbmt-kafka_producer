[![Gem Version](https://badge.fury.io/rb/sbmt-kafka_producer.svg)](https://badge.fury.io/rb/sbmt-kafka_producer)
[![Build Status](https://github.com/SberMarket-Tech/sbmt-kafka_producer/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/SberMarket-Tech/sbmt-kafka_producer/actions?query=branch%3Amaster)

# Sbmt-KafkaProducer

This gem is used for producing Kafka messages. It represents a wrapper over [waterdrop](https://github.com/karafka/waterdrop) gem and is recommended for using as a transport with [sbmt-outbox][https://github.com/SberMarket-Tech/sbmt-outbox] gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "sbmt-kafka_producer"
```

And then execute:

```bash
bundle install
```

## Auto configuration

We recommend going through configuration and files creation with the following Rails generators.

Each generator can be run using the `--help` option to learn more about the available arguments.

### Initial configuration

If you plug the gem into your application for the first time, you can generate the initial configuration:

```shell
rails g kafka_producer:install
```

In the result, the `config/kafka_producer.yml` file will be created.

### Producer class

A producer class can be generated with the following command:

```shell
rails g kafka_producer:producer MaybeNamespaced::Name sync topic
```

In the result, the sync producer will be created.

### Outbox producer

To generate an outbox producer for using with gem [sbmt-outbox](https://github.com/SberMarket-Tech/sbmt-outbox) run the following command:

```shell
rails g kafka_producer:outbox_producer SomeOutboxItem
```

## Manual configuration

The `config/kafka_producer.yml` file is a main config for the gem.

```yaml
default: &default
  deliver: true
  ignore_kafka_error: true
  # see more options at https://github.com/karafka/waterdrop/blob/master/lib/waterdrop/config.rb
  wait_on_queue_full: true
  max_payload_size: 1000012
  max_wait_timeout: 5
  wait_timeout: 0.005
  auth:
    kind: plaintext
  kafka:
    servers: "kafka:9092" # required
    max_retries: 2 # optional, default: 2
    required_acks: -1 # optional, default: -1
    ack_timeout: 1 # in seconds, optional, default: 1
    retry_backoff: 1 # in seconds, optional, default: 1
    connect_timeout: 1 # in seconds, optional, default: 1
    kafka_config: # low-level custom Kafka options
      queue.buffering.max.messages: 1
      queue.buffering.max.ms: 10_000

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

To create a producer that will be responsible for sending message to Kafka, copy the following code:

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

Add the following lines to your `config/outbox.yml` file at the `transports` section:

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

To send a message to a Kafka topic, execute the following:

```ruby
SomeProducer.new.publish(payload, key: "123", headers: {"some-header" => "some-value"})
```

## Metrics

The gem collects base producing metrics using [Yabeda](https://github.com/yabeda-rb/yabeda). See metrics at [YabedaConfigurer](./lib/sbmt/kafka_producer/yabeda_configurer.rb).

## Testing

To stub a producer request to real Kafka broker, you can use a mock. To do this, please add `require "sbmt/kafka_producer/testing"` to the `spec/rails_helper.rb`.

## Development

Install [dip](https://github.com/bibendi/dip).

And run:

```shell
dip provision
dip rspec
```
