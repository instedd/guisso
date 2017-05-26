require "rails_helper"

describe Oauth2::TokenEndpoint do
  let(:endpoint) { Oauth2::TokenEndpoint.new }

  describe "OpenID connect" do
    let(:user) { User.make! }
    let(:client) { Application.make! }
    let(:authorization_code) do
      AuthorizationCode.make!(
        user_id: user.id,
        client_id: client.id,
        resource_id: client.id,
        scope: 'openid',
        redirect_uri: client.redirect_uris.first
      )
    end
    let(:params) do
      {
        grant_type: 'authorization_code',
        client_id: client.identifier,
        code: authorization_code.token,
        redirect_uri: client.redirect_uris.first
      }
    end
    let(:env) do
      Rack::MockRequest.env_for(
        '/oauth2',
        'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64(client.identifier + ":" + client.secret)}",
        params: params
      )
    end

    it "injects id_token in response" do
      status, _header, response = endpoint.call(env)
      expect(status).to eq(200)
      json = JSON.parse(response.body.first)
      expect(json).to include('id_token')
    end
  end
end
