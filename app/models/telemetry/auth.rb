module Telemetry::Auth
  def self.failed
    InsteddTelemetry.counter_add('wrong_password_attempts', {}, 1)
  end

  def self.reset_password
    InsteddTelemetry.counter_add('password_resets', {}, 1)
  end
end
