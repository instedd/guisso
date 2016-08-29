class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :client, class_name: 'Application'
  belongs_to :resource, class_name: 'Application'

  before_destroy :destroy_authorization_codes
  before_destroy :destroy_access_tokens

  private

  def destroy_authorization_codes
    user.authorization_codes.where(client_id: client.id, resource_id: resource.id).delete_all
  end

  def destroy_access_tokens
    user.access_tokens.where(client_id: client.id, resource_id: resource.id).delete_all
  end
end
