# frozen_string_literal: true

class TestGlobalMiddleware
  def call(payload, options)
    yield
  end
end
