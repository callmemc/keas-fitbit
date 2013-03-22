class AddIndexToFitbitCollectedId < ActiveRecord::Migration
  def change
    add_index(:fitbit_collected_ids, :logId, :unique => true)
  end
end
