module Telemetry::Lifespan
  def self.touch_user(user)
    InsteddTelemetry.timespan_update('account_lifespan', {user_id: user.id}, user.created_at, Time.now.utc) if user.present?
  end
end
