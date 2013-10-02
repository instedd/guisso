class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.integer :client_id
      t.integer :resource_id
      t.string :token
      t.string :secret
      t.string :algorithm
      t.integer :refresh_token_id
      t.datetime :expires_at
      t.integer :user_id

      t.timestamps
    end
  end
end
