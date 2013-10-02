class Oauth2::TokenEndpoint
  def call(env)
    authenticator.call(env)
  end

  private

  def authenticator
    Rack::OAuth2::Server::Token.new do |req, res|
      app = Application.find_by(identifier: req.client_id, secret: req.client_secret) or req.invalid_client!
      case req.grant_type
      when :authorization_code
        unless app.trusted && app.is_client
          req.invalid_grant!
        end

        hostname, email = req.code.split ';'

        resource = Application.find_by(hostname: hostname)
        unless resource
          req.invalid_grant!
        end

        user = User.find_by(email: email)
        unless user
          req.invalid_grant!
        end

        access_token = AccessToken.create! client_id: app.id, resource_id: resource.id, user_id: user.id
        res.access_token = access_token.to_mac_token
      else
        req.unsupported_grant_type!
      end
    end
  end

end