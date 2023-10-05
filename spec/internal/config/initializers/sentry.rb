# frozen_string_literal: true

SENTRY_DUMMY_DSN = "http://12345:67890@sentry.localdomain/sentry/42"
Sentry.init do |config|
  config.dsn = SENTRY_DUMMY_DSN
  config.enabled_environments = [Rails.env]
  config.background_worker_threads = 1
  config.transport.transport_class = Class.new(Sentry::HTTPTransport) do
    def send_data(data)
      # for local sentry testing purposes
      Rails.logger.info("sending #{data.inspect} to Sentry")
      sleep 1 # rubocop:disable Rails/CallingSleepInsideTests
    end
  end
  config.traces_sample_rate = 1.0
end
