class Application < ActiveRecord::Base
  before_validation :setup, :on => :create
  validates :name, :secret, :presence => true
  validates :identifier, :presence => true, :uniqueness => true

  private

  def setup
    self.identifier = Oauth2::SecureToken.generate(16)
    self.secret = Oauth2::SecureToken.generate
  end
end