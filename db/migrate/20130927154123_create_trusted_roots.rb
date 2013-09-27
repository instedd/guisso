class CreateTrustedRoots < ActiveRecord::Migration
  def change
    create_table :trusted_roots do |t|
      t.belongs_to :user, index: true
      t.string :url

      t.timestamps
    end
  end
end
