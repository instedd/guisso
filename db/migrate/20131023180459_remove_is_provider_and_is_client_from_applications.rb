class RemoveIsProviderAndIsClientFromApplications < ActiveRecord::Migration
  def change
    remove_column :applications, :is_provider
    remove_column :applications, :is_client
  end
end
