class AddIndexToFitbitCollectedId < ActiveRecord::Migration
  def change
    add_index :fb_collected_logs, :logId
  end
end
