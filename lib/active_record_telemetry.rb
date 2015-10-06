module ActiveRecordTelemetry

  extend ActiveSupport::Concern

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.user)
  end

end

ActiveRecord::Base.send(:include, ActiveRecordTelemetry)
