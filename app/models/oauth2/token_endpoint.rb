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
        unless app.trusted && app.is_client
          req.invalid_grant!
        end

        resource = nil
        user = nil
        req.scope.each do |scope|
          key, value = scope.split '=', 2
          case key
          when 'app'
            resource = Application.find_by(hostname: value)
          when 'user'
            user = User.find_by(email: value)
          end
        end

        unless user && resource
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