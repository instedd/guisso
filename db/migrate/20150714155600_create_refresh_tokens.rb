class CreateRefreshTokens < ActiveRecord::Migration
  def self.up
    create_table :refresh_tokens do |t|
      t.integer :client_id
      t.integer :resource_id
      t.integer :access_token_id
      t.string :token
      t.timestamps
    end
  end

  def self.down
    drop_table :refresh_tokens
  end
end