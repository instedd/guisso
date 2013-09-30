class ExtraPassword < ActiveRecord::Base
  class Strategy < Devise::Strategies::Authenticatable
    def authenticate!
      resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
      return fail(:not_found_in_database) unless resource

      valid = validate(resource) do
        resource.extra_passwords.any? do |extra_password|
          extra_password.valid_password?(password)
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

  def email
    user.email
  end
end
