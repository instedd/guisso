module Oauth2::SecureToken
  def self.generate(bytes = 32)
    SecureRandom.urlsafe_base64(bytes)
  end
end
