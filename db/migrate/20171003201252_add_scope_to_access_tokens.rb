class AddScopeToAccessTokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :scope, :string
  end
end
