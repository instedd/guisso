require 'rails_helper'

describe AccessToken do
  include_examples "user lifespan", described_class

  it 'reports tool usage' do
    client = Application.make!
    resource = Application.make!
    access_token = AccessToken.create! client: client, resource: resource

    expect(Telemetry::ToolUsage).to receive(:report).with(client, resource)

    access_token.report_tool_usage
  end
end
