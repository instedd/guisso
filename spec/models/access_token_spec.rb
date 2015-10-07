require 'rails_helper'

describe AccessToken do
  include_examples "user lifespan", AccessToken

  it 'reports tool usage' do
    client = Application.make!
    resource = Application.make!

    expect(Telemetry::ToolUsage).to receive(:report).with(client, resource)

    AccessToken.create! client: client, resource: resource
  end
end
