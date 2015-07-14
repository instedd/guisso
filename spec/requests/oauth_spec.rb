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
      before(:each) { post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password }

      it "create authorization code" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        post_form create_authorization_path, "approve"

        code = AuthorizationCode.last
        expect(code).not_to be_nil
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end

      it "include state in callback url" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}", state: "foo"
        post_form create_authorization_path, "approve"

        redirect_params = CGI.parse(URI.parse(response.redirect_url).query)
        expect(redirect_params["state"]).to eq(["foo"])
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

      describe "refresh token" do
        it "uses refresh token with bearer" do
          post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, token_type: "bearer",
                                redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: code.token

          response_token = JSON.parse(response.body)
          refresh_token = response_token["refresh_token"]
          expect(refresh_token).not_to be_nil

          refresh_token = RefreshToken.find_by_token(refresh_token)
          expect(refresh_token).not_to be_nil

          post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "refresh_token",
                                refresh_token: refresh_token.token

          response_token = JSON.parse(response.body)
          expect(response_token).not_to be_nil
          expect(response_token["token_type"]).to eq("bearer")

          expect(RefreshToken.count).to eq(1)
          expect(AccessToken.count).to eq(1)
        end
      end
    end
  end
end
