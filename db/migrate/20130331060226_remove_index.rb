class RemoveIndex < ActiveRecord::Migration
  def change
    remove_index :fitbit_collected_ids, :column => :logId
  end
end
