class RemoveLogIdFromMeasurements < ActiveRecord::Migration
  def up
    remove_column :measurements, :logId
  end

  def down
    add_column :measurements, :logId, :integer
  end
end
