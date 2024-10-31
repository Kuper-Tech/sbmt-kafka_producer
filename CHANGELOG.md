# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

### Added

### Changed

### Fixed

## [3.1.1] - 2024-10-31

### Changed

- Update README

## [3.1.0] - 2024-09-13

### Added

- For synchronous messages and errors, we place logs in tags

### Fixed

- Fixed mock for tests

## [3.0.0] - 2024-08-27

## BREAKING

- Drop support for Ruby 2.7
- Drop support for Rails 6.0
- Add support for Waterdrop 2.7
- `wait_timeout` configuration no longer deeded
- All time-related values are now configured in milliseconds: `connect_timeout`, `ack_timeout`, `retry_backoff`, `max_wait_timeout`, `wait_on_queue_full_timeout`

## Added

- Add `message_timeout` configuration

## [2.2.3] - 2024-06-20

### Fixed

- Remove mock for producer client
- A singleton class of the producer client has been added for testing

## [2.2.2] - 2024-06-15

### Fixed

- Fixed display of metrics `kafka_api_calls`  and `kafka_api_errors`

## [2.2.1] - 2024-06-07

### Changed

- Drop support for Rails 5
- Temporary limit upper version of Waterdrop to less than 2.7

## [2.2.0] - 2024-04-12

### Changed

- Add logs with `offset`.

## [2.1.0] - 2024-03-14

### Changed

- Memoize kafka clients. Add a registry with them to KafkaClientFactory.

## [2.0.0] - 2024-01-29

### Changed

- Remove `sbmt-dev`

## [1.0.0] - 2024-01-12

### Added

- Use mainstream karafka instead of custom fork

## [0.8.0] - 2023-10-05

### Added

- Errors' `cause` handling

### Fixed

- change from `double` to `instance_double`

## [0.7.0] - 2023-09-14

### Added

- Plug OpenTelemetry

## [0.6.3] - 2023-08-10

### Fixed

- Return True when publishing with bang methods

## [0.6.2] - 2023-08-08

### Added

- add ErrorTracker for Sentry

## [0.6.1] - 2023-08-07

### Fixed

- Don't catch an exception when publishing through the Sbmt::KafkaProducer::OutboxProducer

## [0.6.0] - 2023-07-23

### Added

- rails generator for initial configuration
- rails generator for producer/outbox_producer creation

## [0.5.1] - 2023-07-21

### Fixed

- change sentry method from capture_message to capture_exception

## [0.5.0] - 2023-06-26

### Fixed
- Mock BaseProducer for rspec

## [Unreleased] - 2023-06-21

### Changed
- update README

## [0.4.2] - 2023-06-20

### Fixed
- fixed version **sbmt-waterdrop**

## [0.4.1] - 2023-06-19

### Fixed
- fixed error handling in the method **on_error_occurred**

## [0.4.0] - 2023-06-13

### Changed
- config changed from anyway to Dry::Struct

## [0.3.0] - 2023-06-01

### Added
- implement producer metrics

## [0.2.3] - 2023-05-19

### Added
- for outbox, if the default settings for the kafka section are overridden, they are overwritten

### Changed

### Fixed

## [0.2.2] - 2023-05-18

### Added
- arbitrary parameters from kafka

### Changed

### Fixed

## [0.2.1] - 2023-05-16

### Added
- fix logger

### Changed

### Fixed

## [0.2.0] - 2023-05-16

### Added
- basic options for producer

### Changed

### Fixed

## [Unreleased] - 2023-05-04

### Added
- basic config for producer via gem anyway_config

### Changed

### Fixed

## [Unreleased] - 2023-05-02

### Added
- BaseProducer
- OutboxProducer
- Sentry, logger

### Changed

### Fixed


## [Unreleased]

## [0.1.0] - 2023-04-17

- Initial release
