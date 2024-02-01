# frozen_string_literal: true

# Engine root is used by rails_configuration to correctly
# load fixtures and support files
require "pathname"
ENGINE_ROOT = Pathname.new(File.expand_path("..", __dir__))

require "spec_helper"
require "combustion"

begin
  Combustion.initialize! :action_controller do
    config.log_level = :fatal if ENV["LOG"].to_s.empty?
    config.i18n.available_locales = %i[ru en]
    config.i18n.default_locale = :ru
  end
rescue => e
  # Fail fast if application couldn't be loaded
  warn "💥 Failed to load the app: #{e.message}\n#{e.backtrace.join("\n")}"
  exit(1)
end

require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "yabeda"
require "yabeda/rspec"

# when using with combustion, anyway is required earlier than rails
# so it's railtie does nothing, but that require is cached
# we must require it explicitly to force anyway autoload our configs
require "anyway/rails" if defined?(Rails::Railtie)

require "sbmt/kafka_producer/instrumentation/open_telemetry_loader"

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
