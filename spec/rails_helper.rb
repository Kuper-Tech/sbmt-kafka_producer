# frozen_string_literal: true

require "spec_helper"
require "combustion"

# when using with combustion, anyway is required earlier than rails
# so it's railtie does nothing, but that require is cached
# we must require it explicitly to force anyway autoload our configs
require "anyway/rails" if defined?(Rails::Railtie)

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

require "sbmt/dev/testing/rails_configuration"
