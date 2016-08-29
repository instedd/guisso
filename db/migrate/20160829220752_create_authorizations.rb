class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer :client_id
      t.integer :resource_id
      t.integer :user_id
    end

    add_index :authorizations, [:user_id, :client_id, :resource_id], :unique => true
  end
end
