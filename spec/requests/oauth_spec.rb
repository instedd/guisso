require 'rails_helper'

describe "OAuth" do
  let(:client_app) { Application.make! redirect_uris: ["http://myapp.com"] }
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
        authorization = Authorization.last
        expect(code).not_to be_nil
        expect(authorization).not_to be_nil
        expect(authorization.client_id).to eq(client_app.id)
        expect(authorization.resource_id).to eq(resource_app.id)
        expect(authorization.user_id).to eq(user.id)
        expect(authorization.scope).to eq("all")
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end

      it "stores normalized scope in authorization and code" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo=1 bar=2"
        post_form create_authorization_path, "approve"

        code = AuthorizationCode.last
        authorization = Authorization.last
        expect(code.scope).to eq("bar=2 foo=1")
        expect(authorization.scope).to eq("bar=2 foo=1")
      end

      it "authorizes implicitly the second time" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        code = AuthorizationCode.last
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end

      it "authorizes implicitly the second time with scope elements in different order" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo=1"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "foo=1 app=#{resource_app.hostname}"
        code = AuthorizationCode.last
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end

      it "authorizes implicitly the second time with all scope" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "foo=1 app=#{resource_app.hostname}"
        code = AuthorizationCode.last
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end

      it "authorizes implicitly the second time with smaller scope" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo bar"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo"
        code = AuthorizationCode.last
        expect(response).to redirect_to("http://myapp.com?code=#{code.token}")
      end

      it "does not authorizes implicitly the second time with a different scope" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} bar"
        expect(response).to be_successful # does not redirect
      end

      it "does not authorizes implicitly the second time with a larger scope" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo bar"
        expect(response).to be_successful # does not redirect
      end

      it "does not authorizes implicitly the second time with largest scope" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        expect(response).to be_successful # does not redirect
      end

      it "accumulate scopes in authorization" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} bar"
        post_form create_authorization_path, "approve"

        authorization = Authorization.last
        expect(authorization.scope).to eq("bar foo")
      end

      it "doesn't accumulate if existing authorization is 'all'" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} bar"

        authorization = Authorization.last
        expect(authorization.scope).to eq("all")
      end

      it "saturates scope to 'all" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname} foo"
        post_form create_authorization_path, "approve"

        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}"
        post_form create_authorization_path, "approve"

        authorization = Authorization.last
        expect(authorization.scope).to eq("all")

      end

      it "include state in callback url" do
        get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "code", scope: "app=#{resource_app.hostname}", state: "foo"
        post_form create_authorization_path, "approve"

        redirect_params = CGI.parse(URI.parse(response.redirect_url).query)
        expect(redirect_params["state"]).to eq(["foo"])
      end
    end

    describe "Client Flow" do
      let(:code) { AuthorizationCode.make! user: user, client_id: client_app.id, resource_id: resource_app.id, redirect_uri: "http://myapp.com", scope: 'foo=1' }

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

      it "generates token with same scope" do
        post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret,
                              redirect_uri: "http://myapp.com", grant_type: "authorization_code", code: code.token

        response_token = JSON.parse(response.body)
        token = AccessToken.find_by_token(response_token["access_token"])
        expect(token.scope).to eq("foo=1")
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
          expect(response_token["refresh_token"]).to eq(refresh_token.token)

          expect(RefreshToken.count).to eq(1)
          expect(AccessToken.count).to eq(2)

          expect(AccessToken.last.scope).to eq(AccessToken.first.scope)
        end
      end
    end
  end

  describe "Client Credentials Grant" do
    it "trusted client gets token with default options" do
      client_app.trusted = true
      client_app.save!

      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "client_credentials",
                            scope: "user=#{user.email} app=#{resource_app.hostname}"

      response_token = JSON.parse(response.body)
      expect(response_token["token_type"]).to eq("mac")
      expect(response_token["expires_in"]).to be <= 15.minutes
    end

    it "creates token with specified scope" do
      client_app.trusted = true
      client_app.save!

      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "client_credentials",
                            scope: "user=#{user.email} app=#{resource_app.hostname} foo=1"

      expect(AccessToken.last.scope).to eq("app=#{resource_app.hostname} foo=1 user=#{user.email}")
    end

    it "non trusted client should not get a token" do
      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "client_credentials",
                            scope: "user=#{user.email} app=#{resource_app.hostname}"

      expect(response).to have_http_status(400)
    end

    it "non trusted client can get token to access itself" do
      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "client_credentials",
                            scope: "user=#{user.email}"

      response_token = JSON.parse(response.body)
      expect(response).to be_successful
      token = AccessToken.find_by_token!(response_token["access_token"])
      expect(token.resource_id).to eq(client_app.id)
    end
  end

  describe "Implicit Grant" do
    before(:each) { post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password }

    it "creates token" do
      get "/oauth2/authorize", client_id: client_app.identifier, redirect_uri: "http://myapp.com", response_type: "token", scope: "app=#{resource_app.hostname}"
      post_form create_authorization_path, "approve"

      token = AccessToken.last
      authorization = Authorization.last
      expect(token).not_to be_nil
      expect(token.token_type).to eq("bearer")
      expect(authorization).not_to be_nil
      expect(authorization.client_id).to eq(client_app.id)
      expect(authorization.resource_id).to eq(resource_app.id)
      expect(authorization.user_id).to eq(user.id)
      expect(response).to redirect_to("http://myapp.com#access_token=#{token.token}&expires_in=3599&token_type=bearer")
    end
  end

  describe "Exchange Token" do
    it "exchange a bearer token" do
      token = BearerAccessToken.make! client: client_app, resource: resource_app, user: user, scope: "all"
      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "token_exchange",
                            scope: "foo bar", access_token: token.token

      expect(response).to be_successful
      response_token = JSON.parse(response.body)
      token = AccessToken.find_by_token!(response_token["access_token"])
      expect(token.token_type).to eq("bearer")
      expect(token.user_id).to eq(user.id)
      expect(token.client_id).to eq(client_app.id)
      expect(token.resource_id).to eq(resource_app.id)
      expect(token.scope).to eq("bar foo")
    end

    it "cannot exchange access_token of another app" do
      token = BearerAccessToken.make! client: resource_app, resource: resource_app, user: user, scope: "foo"
      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "token_exchange",
                            scope: "foo", access_token: token.token
      expect(response).to have_http_status(400)
    end

    it "cannot exchange access_token with smaller scope" do
      token = BearerAccessToken.make! client: client_app, resource: resource_app, user: user, scope: "foo"
      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "token_exchange",
                            scope: "all", access_token: token.token
      expect(response).to have_http_status(400)
    end

    it "cannot exchange expired access_token" do
      token = BearerAccessToken.make! client: client_app, resource: resource_app, user: user, scope: "all", expires_at: Time.now.utc
      post "/oauth2/token", client_id: client_app.identifier, client_secret: client_app.secret, grant_type: "token_exchange",
                            scope: "all", access_token: token.token
      expect(response).to have_http_status(400)
    end
  end
end
