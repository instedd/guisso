class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  devise :confirmable if Guisso::Settings.devise_confirmable

  has_many :identities, dependent: :destroy
  has_many :trusted_roots, dependent: :destroy
  has_many :extra_passwords, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :authorization_codes, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :authorizations, dependent: :destroy

  after_save :touch_lifespan
  after_destroy :touch_lifespan

  enumerated_attribute :role, %w(user admin) do
    label :user => 'User'
    label :admin => 'Administrator'
  end

  def name_with_email
    if name.present?
      "#{name} <#{email}>"
    else
      email
    end
  end

  def admin?
    role == :admin
  end

  def create_openid_token_for(app, issuer = "login.instedd.org")
    # See http://openid.net/specs/openid-connect-core-1_0.html#IDToken
    payload = {
      iss: issuer,
      sub: id.to_s,
      aud: app.identifier,
      email: email,
      exp: 5.minutes.from_now.to_i,
      iat: Time.now.to_i
    }

    # Sign the token using the client's secret
    JWT.encode payload, app.secret, 'HS512'
  end

  private

  def touch_lifespan
    Telemetry::Lifespan.touch_user(self)
  end

end
