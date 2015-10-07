require 'rails_helper'

describe Telemetry::ToolUsage do
  it 'reports tool usage with client and resource' do
    client = Application.make! name: 'mbuilder'
    resource = Application.make! name: 'resmap'

    expect(InsteddTelemetry).to receive(:counter_add).with('tool_usage', {client: 'mbuilder', resource: 'resmap'}, 1)

    Telemetry::ToolUsage.report(client, resource)
  end

  it 'should not report if client or resource is missing' do
    app = Application.make! name: 'mbuilder'

    expect(InsteddTelemetry).not_to receive(:counter_add)

    Telemetry::ToolUsage.report(app, nil)
    Telemetry::ToolUsage.report(nil, app)
  end
end
