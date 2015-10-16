require 'rails_helper'

describe Oauth2Controller do
  describe '#GET trusted token' do
    describe 'telemetry' do
      let!(:resource) { Application.make! trusted: true }
      let!(:client) { Application.make! trusted: true }
      let!(:access_token) { AccessToken.make! client: client, resource: resource}

      it 'reports tool usage when validating token' do
        expect(Telemetry::ToolUsage).to receive(:report).with(client, resource)

        get :trusted_token, identifier: resource.identifier, secret: resource.secret, token: access_token.token
      end
    end
  end
end
