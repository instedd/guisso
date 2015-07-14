class RefreshToken < ActiveRecord::Base
  before_validation :setup, :on => :create

  belongs_to :access_token

  private

  def setup
    self.token = ::Oauth2::SecureToken.generate
  end
end