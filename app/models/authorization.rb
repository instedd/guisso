class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :client, class_name: 'Application'
  belongs_to :resource, class_name: 'Application'

  before_destroy :destroy_authorization_codes
  before_destroy :destroy_access_tokens

  def is_openid?
    client == resource && scope.split.include?("openid")
  end

  def self.normalize_scope(scope)
    scope
      .reject { |s|
        s.starts_with?("app=") ||
        s.starts_with?("user=") ||
        s.starts_with?("token_type=") ||
        s.starts_with?("never_expires=")
      }
      .sort
      .presence || ["all"]
  end

  def self.scope_included?(scope, test_scope)
    return true if scope == "all"
    scopes = scope.split
    test_scope.split.all? { |s| scopes.include?(s) }
  end

  def includes_scope?(test_scope)
    Authorization.scope_included?(scope, test_scope)
  end

  def add_scope(new_scopes)
    return if scope == "all"
    if new_scopes == "all"
      self.scope = "all"
    else
      self.scope = (scope.split + new_scopes.split).uniq.sort.join(' ')
    end
  end

  private

  def destroy_authorization_codes
    user.authorization_codes.where(client_id: client.id, resource_id: resource.id).delete_all
  end

  def destroy_access_tokens
    user.access_tokens.where(client_id: client.id, resource_id: resource.id).delete_all
  end
end
