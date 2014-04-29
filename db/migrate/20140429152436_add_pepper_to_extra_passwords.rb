class AddPepperToExtraPasswords < ActiveRecord::Migration
  def change
    add_column :extra_passwords, :pepper, :string, default: nil
  end
end
