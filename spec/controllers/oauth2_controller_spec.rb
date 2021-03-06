require 'rails_helper'

describe Oauth2Controller do
  describe '#GET trusted token' do
    let!(:user) { User.make! }
    let!(:resource) { Application.make! }
    let!(:client) { Application.make! }
    let!(:access_token) { BearerAccessToken.make! client: client, resource: resource, user: user, scope: "foo=1" }

    describe 'telemetry' do
      it 'reports tool usage when validating token' do
        expect(Telemetry::ToolUsage).to receive(:report).with(client, resource)

        get :trusted_token, identifier: resource.identifier, secret: resource.secret, token: access_token.token
      end
    end

    it 'contains the token scope' do
      get :trusted_token, identifier: resource.identifier, secret: resource.secret, token: access_token.token
      response_token = JSON.parse(response.body)

      expect(response_token["scope"]).to eq("foo=1")
    end
  end

  describe 'OpenID connect' do
    describe '#GET authorize' do
      let!(:user) { User.make! }
      let!(:client) { Application.make! }
      before(:each) do
        sign_in user
      end

      it 'renders authorization page' do
        get :authorize, client_id: client.identifier, response_type: :code, scope: 'openid', redirect_uri: client.redirect_uris.first

        expect(response.status).to eq(200)
        expect(response).to render_template :authorize
      end

      it 'redirects with authorization code' do
        post :create_authorization, approve: true, client_id: client.identifier, response_type: :code, scope: 'openid', redirect_uri: client.redirect_uris.first

        expect(response.status).to eq(302)
        md = /#{client.redirect_uris.first}\?code=(?<code>.+)/.match response.location
        expect(md).to_not be_nil
        auth_code = AuthorizationCode.find_by(token: md[:code])
        expect(auth_code).to_not be_nil
        expect(auth_code.client_id).to eq(client.id)
        expect(auth_code.resource_id).to eq(client.id)
        expect(auth_code.scope).to eq("openid")
      end

      it 'propagates client provided state' do
        user.authorizations.create client: client, resource: client, scope: 'openid'

        get :authorize, client_id: client.identifier, response_type: :code, scope: 'openid', redirect_uri: client.redirect_uris.first, state: 'foobar'

        expect(response.status).to eq(302)
        redirect_uri = URI(response.location)
        params = Rack::Utils.parse_query(redirect_uri.query)
        expect(params).to include("state")
        expect(params["state"]).to eq('foobar')
      end
    end
  end
end
