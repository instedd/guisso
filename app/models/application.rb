class Application < ActiveRecord::Base
  before_validation :setup, :on => :create
  validates :name, :secret, :presence => true
  validates :identifier, :presence => true, :uniqueness => true
  validates :hostname, :presence => true, :uniqueness => true

  belongs_to :user

  private

  def setup
    self.identifier = Oauth2::SecureToken.generate(16)
    self.secret = Oauth2::SecureToken.generate
  end
end
