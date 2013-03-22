class RenameFitbitCollectedId < ActiveRecord::Migration
  def up
    rename_table :fitbit_collected_ids, :fb_collected_logs
  end

  def down
    rename_table :fb_collected_logs, :fitbit_collected_ids
  end
end
