require 'rails_helper'

describe "OAuth" do
  let(:client_app) { Application.make! }
  let(:resource_app) { Application.make! }
  let(:user) { User.make! }

  it "redirects to login when signed out" do
    get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
    expect(response).to redirect_to(new_user_session_url)
  end

  describe "Authorization Code Grant" do
    describe "User Flow" do
      it "create authorization code" do
        post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        post_params = {}
        assert_select "form[action=#{create_authorization_path}]" do |form|
          assert_select "input[type=hidden]" do |input|
            post_params = Hash[input.map {|i| [i.attributes["name"], i.attributes["value"]]}]
          end

          assert_select "input[name=approve][type=submit]", 1 do |approve|
            post_params["approve"] = approve.first["value"]
          end
        end

        post create_authorization_path, post_params
        code = AuthorizationCode.last
        expect(code).not_to be_nil
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end
    end

    describe "Client Flow" do
      let(:code) { AuthorizationCode.make! user: user, client_id: client_app.id, resource_id: resource_app.id, redirect_uri: "http://myapp.com" }

      it "create mac token (by default)" do
        post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret,
                              redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: code.token

        response_token = JSON.parse(response.body)
        token = AccessToken.last
        expect(token.client_id).to eq(client_app.id)
        expect(token.resource_id).to eq(resource_app.id)
        expect(response_token["token_type"]).to eq("mac")
        expect(response_token["mac_algorithm"]).to eq(token.algorithm)
        expect(response_token["access_token"]).to eq(token.token)
        expect(response_token["mac_key"]).to eq(token.secret)
      end

      it "create bearer token (with token_type=bearer)" do
        post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, token_type: "bearer",
                              redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: code.token

        response_token = JSON.parse(response.body)
        token = AccessToken.last
        expect(response_token["token_type"]).to eq("bearer")
      end

      it "denies access if client_id/client_secret is invalid" do
        post "/oauth2/token", client_id: client_app.identifier, client_secret: "invalid secret",
                              redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: code.token

        expect(response).to have_http_status(401)
        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to eq("invalid_client")
      end

      it "denies access if redirect_uri doesn't match" do
        post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret,
                              redirect_uri: "http://anotherapp.com", grant_type: "authorization_code", code: code.token

        expect(response).to have_http_status(400)
        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to eq("invalid_grant")
      end

      it "denies access if code doesn't match" do
        post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret,
                              redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: "invalid code"

        expect(response).to have_http_status(400)
        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to eq("invalid_grant")
      end

      it "denies access if code is expired" do
        code.expired!
        post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret,
                              redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: code.token

        expect(response).to have_http_status(400)
        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to eq("invalid_grant")
      end
    end
  end
end
