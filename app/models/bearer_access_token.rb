class BearerAccessToken < AccessToken
  def to_token(with_refresh_token = false)
    bearer_token = Rack::OAuth2::AccessToken::Bearer.new(
      :access_token => self.token,
      :expires_in => self.expires_in
    )
    if with_refresh_token
      bearer_token.refresh_token = RefreshToken.create!(
        :client_id => self.client_id,
        :resource_id  => self.resource_id,
        :access_token_id => self.id,
      ).token
    end
    bearer_token
  end

  def token_type
    "bearer"
  end
end
