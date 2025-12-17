# frozen_string_literal: true

require_relative "../../app/middlewares/test_global_middleware"

Sbmt::KafkaProducer.middlewares.push(
  TestGlobalMiddleware
)
