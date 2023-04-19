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
