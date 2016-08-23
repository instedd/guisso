class Oauth2::TokenEndpoint
  def call(env)
    authenticator.call(env)
  end

  private

  def authenticator
    Rack::OAuth2::Server::Token.new do |req, res|
      app = Application.find_by(identifier: req.client_id, secret: req.client_secret) or req.invalid_client!
      case req.grant_type
      when :client_credentials
        resource = app
        user = nil
        token_type = MacAccessToken
        expires_at = nil
        req.scope.each do |scope|
          key, value = scope.split '=', 2
          case key
          when 'app'
            unless app.trusted
              req.invalid_grant!
            end
            resource = Application.find_by(hostname: value)
          when 'user'
            user = User.find_by(email: value)
          when 'token_type'
            if value == 'bearer'
              token_type = BearerAccessToken
            end
          when 'never_expires'
            if value == 'true'
              expires_at = 1000.years.from_now
            end
          end
        end

        unless app && resource && user
          req.invalid_grant!
        end

        access_token = token_type.create! client_id: app.id, resource_id: resource.id, user_id: user.id, expires_at: expires_at
        res.access_token = access_token.to_token(:with_refresh_token)
      when :authorization_code
        code = AuthorizationCode.valid.find_by_token(req.code)
        req.invalid_grant! if code.blank? || code.redirect_uri != req.redirect_uri
        token_type = req.params["token_type"] == "bearer" ? BearerAccessToken : MacAccessToken
        res.access_token = code.create_access_token(token_type).to_token(:with_refresh_token)
      when :refresh_token
        refresh_token = app.refresh_tokens.find_by_token(req.refresh_token)
        req.invalid_grant! unless refresh_token
        access_token = refresh_token.access_token
        req.invalid_grant! unless access_token
        new_access_token = access_token.class.create! client_id: access_token.client_id, resource_id: access_token.resource_id, user_id: access_token.user_id
        res.access_token = new_access_token.to_token(:with_refresh_token)

        access_token.destroy!
        refresh_token.destroy!
      else
        req.unsupported_grant_type!
      end
    end
  end

end
