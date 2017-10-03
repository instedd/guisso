class AddScopeToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :scope, :string
  end
end
