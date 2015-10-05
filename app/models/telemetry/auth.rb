module Telemetry::Auth
  def self.failed
    InsteddTelemetry.counter_add('wrong_password_attempts', {}, 1)
  end
end
