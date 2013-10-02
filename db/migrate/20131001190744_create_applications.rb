class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :identifier
      t.string :secret
      t.string :name
      t.string :hostname
      t.boolean :is_client
      t.boolean :is_provider
      t.boolean :trusted

      t.timestamps
    end
  end
end
