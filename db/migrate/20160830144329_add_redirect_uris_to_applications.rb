class AddRedirectUrisToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :redirect_uris, :text
  end
end
