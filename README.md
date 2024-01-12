# Sbmt::KafkaProducer


## Гем для продюсинга сообщений из kafka

- представляет собой абстракцию над используемым кафка-клиентом (на данный момент это karafka 2)
- предоставляет более удобное конфигурирование продюсеров, а также возможность использования [Outbox Pattern](https://gitlab.sbmt.io/paas/rfc/-/tree/master/text/paas-2219-outbox) из коробки совместно с гемом [Outbox](https://gitlab.sbmt.io/nstmrt/rubygems/outbox)

## Подключение и конфигурация

Добавить в Gemfile
```ruby
gem "sbmt-kafka_producer", "~> 0.6"
```

Выполнить
```bash
bundle install
```

Создать и настроить конфигурационный файл config/kafka_producer.yml.
Для быстрой настройки см. раздел [Генераторы](#генераторы).
Пример (см. описание в разделах ниже):

```yaml
default: &default
  deliver: true
  wait_on_queue_full: true
  max_payload_size: 1000012
  max_wait_timeout: 5
  wait_timeout: 0.005
  ignore_kafka_error: true
  auth:
    kind: plaintext
  kafka:
    servers: "kafka:9092"
    max_retries: 2 # message.send.max.retries default: 2
    required_acks: -1 # request.required.acks default: -1
    ack_timeout: 1 # request.timeout.ms, указывается числов в секундах default: 1
    retry_backoff: 1 # retry.backoff.ms, указывается числов в секундах default: 1
    connect_timeout: 1 # socket.connection.setup.timeout.ms, указывается числов в секундах default: 1
    kafka_config:
      queue.buffering.max.messages: 1
      queue.buffering.max.ms: 10_000
development:
  <<: *default 
test:
  <<: *default
  deliver: false
  wait_on_queue_full: false
staging: &staging
  <<: *default
production:
  <<: *staging
```

#### Конфигурация: блок `default`

Опции для `waterdrop` определены вот [тут](https://github.com/karafka/waterdrop/blob/master/lib/waterdrop/config.rb#L25)

Опция `ignore_kafka_error` кастомная и отключает логирование ошибок в `Rails.logger` и `Sentry`

#### Конфигурация: блок `auth`

Поддерживаются две версии: plaintext (дефолт, если не указывать) и SASL-plaintext

Вариант конфигурации SASL-plaintext:
```yaml
auth:
  kind: sasl_plaintext
  sasl_username: user
  sasl_password: pwd
  sasl_mechanism: SCRAM-SHA-512
```

#### Конфигурация: блок `kafka`

Обязательной опцией является `servers` в формате rdkafka (**без префикса схемы** `kafka://`): `srv1:port1,srv2:port2,...`
В разделе `kafka_config` можно указать (любые опции rdkafka)[https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md]

## Генераторы

Для упрощения настройки и создания producer реализованы rails-генераторы

### Настройка первоначальной конфигурации гема

Если подключаете sbmt-kafka_producer в свое приложения впервые, можно сгенерировать первоначальную базовую конфигурацию:

```shell
bundle exec rails g kafka_producer:install
```

В результате будут создан основной конфиг гема

### Создание producer

Сгенерировать producer можно следующим образом:

```shell
bundle exec rails g kafka_producer:producer MaybeNamespaced::Name sync topic
```

В результате будет создан базовый продюсер для синхронного стриминга в кафку

Более подробно перечень опций генератора можно посмотреть в help:

```shell
bin/rails generate kafka_producer:producer --help
```

### Создание outbox_producer

Для использования совместно с гемом [outbox](https://gitlab.sbmt.io/nstmrt/rubygems/outbox), нужно выполнить:

```shell
bundle exec rails g kafka_producer:outbox_producer name
```

В результате будут внесены изменения в `config/outbox.yaml` для вашего outbox_item

### Конфигурация `producer` (не outbox) пример:

- Создать базовый класс `applicaton_producer.rb` в `app/producers/`

```ruby
# frozen_string_literal: true

class ApplicationProducer < Sbmt::KafkaProducer::BaseProducer; end
```

- Создать `producer`, который будет продюсить сообщения:

**Синхронный**
```ruby
# frozen_string_literal: true

class SomeProducer < ApplicationProducer
  option :topic, default: -> { 'topic' }

  def publish(payload, options) # options - не обязательный и должен быть в виде хэша
    sync_publish(payload, options)
  end
end
```

**Асинхронный**
```ruby
# frozen_string_literal: true

class SomeProducer < ApplicationProducer
  option :topic, default: -> { 'topic' }

  def publish(payload, options) # options - не обязательный и должен быть в виде хэша
    async_publish(payload, options)
  end
end
```

- Продюсить сообщения в кафку:

```ruby
SomeProducer.new.publish(payload)
```

### Конфигурация `producer` (outbox) пример:

В файл `config/outbox.yml` добавить секицю `transports`

```yaml
outbox_items:
  export_outbox_item:
    transports:
      sbmt/kafka_producer:
        topic: 'topic'
        kafka:
          required_acks: -1
```

### Метрики

Гем собирает базовые продюсинг метрики в yabeda, см. `YabedaConfigurer`
Для начала работы достаточно в основном приложении подключить любой поддерживаемый yabeda-экспортер (например, `yabeda-prometheus-mmap`) и метрики станут доступны из коробки

**NOTE:** При использовании **Yabeda** в **rails** приложении необходимо добавить:

```ruby
# We must manually require this file because Yabeda gem depends on Anyway gem
# and is loaded as a Puma plugin before Rails initialization.
require "anyway/rails"
```

в `config/application.rb` после `Bundler.require`

### RSpec

Так как при тестирование **producer** пытается создать соединение с кафкой, необходимо в `spec/rails_helper.rb` добавить `require 'sbmt/kafka_producer/testing'`
Это из коробки создает `mock` объекта

## Разработка

### Локальное окружение

1. Подготовка рабочего окружения
```shell
dip provision
```
2. Запуск тестов
```shell
dip rspec
```
3. Запуск сервера
```shell
dip up
```
