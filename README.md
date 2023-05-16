# Sbmt::KafkaProducer


## Гем для продюсинга сообщений из kafka

- представляет собой абстракцию над используемым кафка-клиентом (на данный момент это karafka 2)
- предоставляет более удобное конфигурирование продюсеров, а также возможность использования [Outbox Pattern](https://gitlab.sbmt.io/paas/rfc/-/tree/master/text/paas-2219-outbox) из коробки совместно с гемом [Outbox](https://gitlab.sbmt.io/nstmrt/rubygems/outbox)

## Подключение и конфигурация

Добавить в Gemfile
```ruby
gem "sbmt-kafka_producer", "~> 0.1.0"
```

Выполнить
```bash
bundle install
```

Создать и настроить конфигурационный файл config/kafka_producer.yml, пример конфига:
```ruby
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
    kafka_config:
      required_acks: -1
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