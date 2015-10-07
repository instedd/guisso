module Telemetry::ToolUsage
  def self.report(client_app, resource_app)
    if client_app.present? && resource_app.present?
      InsteddTelemetry.counter_add('tool_usage', {client: client_app.name, resource: resource_app.name}, 1)
    end
  end
end
