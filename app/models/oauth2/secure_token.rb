module Oauth2::SecureToken
  def self.generate(bytes = 64)
    SecureRandom.base64(bytes)
  end
end