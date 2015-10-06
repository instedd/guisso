class AuthorizationCode < ActiveRecord::Base
  include Oauth2::Token

  belongs_to :user

  after_save :touch_user_lifespan

  def create_access_token(token_type)
    expired! && user.access_tokens.create(client_id: client_id, resource_id: resource_id, type: token_type.to_s)
  end
end
