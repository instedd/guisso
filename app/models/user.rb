class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  devise :confirmable if Guisso::Settings.devise_confirmable

  has_many :identities, dependent: :destroy
  has_many :trusted_roots, dependent: :destroy
  has_many :extra_passwords, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :authorization_codes, dependent: :destroy
  has_many :access_tokens, dependent: :destroy

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

end
