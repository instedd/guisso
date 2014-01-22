class StiForAccessToken < ActiveRecord::Migration
  def up
    add_column :access_tokens, :type, :string
    execute "update access_tokens set type = 'MacAccessToken'"
  end

  def down
    remove_column :access_tokens, :type
  end
end
