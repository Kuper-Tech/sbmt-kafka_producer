# frozen_string_literal: true

require_relative "lib/sbmt/kafka_producer/version"

Gem::Specification.new do |spec|
  spec.name = "sbmt-kafka_producer"
  spec.license = "MIT"
  spec.version = Sbmt::KafkaProducer::VERSION
  spec.authors = ["Kuper Ruby-Platform Team"]

  spec.summary = "Ruby gem for producing Kafka messages"
  spec.description = "This gem is used for producing Kafka messages. It represents a wrapper over Waterdrop gem and is recommended for using as a transport with sbmt-outbox"
  spec.homepage = "https://github.com/Kuper-Tech/sbmt-kafka_producer"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = ENV.fetch("NEXUS_URL", "https://rubygems.org")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "false" # rubocop:disable Gemspec/RequireMFA

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "anyway_config", "~> 2.4"
  spec.add_dependency "connection_pool", "~> 2.0"
  spec.add_dependency "dry-initializer", "~> 3.0"
  spec.add_dependency "dry-struct", "~> 1.5"
  spec.add_dependency "waterdrop", "~> 2.7", "< 2.8"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "yabeda", "~> 0.11"

  spec.add_development_dependency "appraisal", ">= 2.4"
  spec.add_development_dependency "bundler", ">= 2.1"
  spec.add_development_dependency "combustion", ">= 1.3"
  spec.add_development_dependency "opentelemetry-sdk"
  spec.add_development_dependency "opentelemetry-api", ">= 0.17.0"
  spec.add_development_dependency "opentelemetry-common", ">= 0.17.0"
  spec.add_development_dependency "opentelemetry-instrumentation-base", ">= 0.17.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rails", ">= 6.1"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "rspec_junit_formatter", ">= 0.6"
  spec.add_development_dependency "rspec-rails", ">= 4.0"
  spec.add_development_dependency "rubocop-rails", ">= 2.5"
  spec.add_development_dependency "rubocop-rspec", ">= 2.11"
  spec.add_development_dependency "sentry-ruby", "> 5.16"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "standard", ">= 1.12"
end
