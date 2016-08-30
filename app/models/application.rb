class Application < ActiveRecord::Base
  before_validation :setup, :on => :create
  validates :name, :secret, :presence => true
  validates :identifier, :presence => true, :uniqueness => true
  validates :hostname, :presence => true, :uniqueness => true

  belongs_to :user
  has_many :refresh_tokens, :foreign_key => :client_id
  serialize :redirect_uris, Array

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  private

  def setup
    self.identifier = Oauth2::SecureToken.generate(16)
    self.secret = Oauth2::SecureToken.generate
  end
end
