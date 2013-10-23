class CreateAuthorizationCodes < ActiveRecord::Migration
  def change
    create_table :authorization_codes do |t|
      t.integer :user_id
      t.integer :client_id
      t.integer :resource_id
      t.string :token
      t.string :redirect_uri
      t.datetime :expires_at

      t.timestamps
    end
  end
end
