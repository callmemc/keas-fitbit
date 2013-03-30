class RenameDeviceIdColumn < ActiveRecord::Migration
  def change
    rename_column :fb_collected_logs, :device_id, :user_id
  end
end
