class ExtraPassword < ActiveRecord::Base
  class Strategy < Devise::Strategies::Authenticatable
    def authenticate!
      resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
      return fail(:not_found_in_database) unless resource

      valid = validate(resource) do
        resource.extra_passwords.any? do |extra_password|
          extra_password.valid_password?(password, extra_password.pepper)
        end
      end

      if valid
        resource.after_database_authentication
        success!(resource)
      end
    end

    def validate(resource, &block)
      result = resource && resource.valid_for_authentication?(&block)

      if result
        decorate(resource)
        true
      else
        false
      end
    end
  end

  include Devise::Models::DatabaseAuthenticatable

  belongs_to :user

  validates_presence_of :user, :email, :encrypted_password

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  def email
    user.email
  end

  def valid_password?(password, pepper = self.pepper)
    return false if encrypted_password.blank?
    bcrypt   = ::BCrypt::Password.new(encrypted_password)
    password = ::BCrypt::Engine.hash_secret("#{password}#{pepper}", bcrypt.salt)
    Devise.secure_compare(password, encrypted_password)
  end
end
