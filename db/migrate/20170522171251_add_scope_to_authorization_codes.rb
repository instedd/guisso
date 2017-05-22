class AddScopeToAuthorizationCodes < ActiveRecord::Migration
  def change
    add_column :authorization_codes, :scope, :string
  end
end
