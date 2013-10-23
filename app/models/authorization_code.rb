class AuthorizationCode < ActiveRecord::Base
  include Oauth2::Token

  belongs_to :user

  def create_access_token
    expired! && user.access_tokens.create(client_id: client_id, resource_id: resource_id)
  end
end
