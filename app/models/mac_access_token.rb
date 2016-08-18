class MacAccessToken < AccessToken
  validates :secret, :presence => true
  validates :algorithm, :presence => true, :inclusion => %w(hmac-sha-1 hmac-sha-256)

  def to_token(with_refresh_token = false)
    mac_token = Rack::OAuth2::AccessToken::MAC.new(
      :access_token  => self.token,
      :mac_key       => self.secret,
      :mac_algorithm => self.algorithm,
      :expires_in    => self.expires_in
    )
    if with_refresh_token
      mac_token.refresh_token = RefreshToken.create!(
        :client_id => self.client_id,
        :resource_id  => self.resource_id,
        :access_token_id => self.id,
      ).token
    end
    mac_token
  end

  def token_type
    "mac"
  end

  def as_json(options = nil)
    super.tap do |json|
      json[:mac_key] = secret
      json[:mac_algorithm] = algorithm
    end
  end

  private

  def setup
    super
    self.algorithm = 'hmac-sha-256'
    self.secret = Oauth2::SecureToken.generate
  end
end
