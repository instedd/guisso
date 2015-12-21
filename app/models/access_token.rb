class AccessToken < ActiveRecord::Base
  include Oauth2::Token

  self.default_lifetime = 15.minutes

  belongs_to :resource, class_name: 'Application'
  belongs_to :client, class_name: 'Application'
  belongs_to :user

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  def report_tool_usage
    Telemetry::ToolUsage.report(self.client, self.resource)
  end
end
