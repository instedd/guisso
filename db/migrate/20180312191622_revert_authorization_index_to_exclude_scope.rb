class RevertAuthorizationIndexToExcludeScope < ActiveRecord::Migration
  def up
    remove_index :authorizations, name: "authorizations_by_user_client_resource_and_scope"
    add_index :authorizations, [:user_id, :client_id, :resource_id], :unique => true
  end

  def down
    remove_index :authorizations, [:user_id, :client_id, :resource_id]
    add_index :authorizations, [:user_id, :client_id, :resource_id, :scope], unique: true, name: "authorizations_by_user_client_resource_and_scope"
  end
end
