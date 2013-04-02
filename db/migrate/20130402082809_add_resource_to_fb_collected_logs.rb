class AddResourceToFbCollectedLogs < ActiveRecord::Migration
  def change
    add_column :fb_collected_logs, :resource, :integer
  end
end
