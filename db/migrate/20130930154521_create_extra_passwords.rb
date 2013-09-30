class CreateExtraPasswords < ActiveRecord::Migration
  def change
    create_table :extra_passwords do |t|
      t.integer :user_id
      t.string :encrypted_password

      t.timestamps
    end
  end
end
