# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

### Added

### Changed

### Fixed

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
