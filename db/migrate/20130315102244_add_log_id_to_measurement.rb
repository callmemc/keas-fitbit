class AddLogIdToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :logId, :integer
  end
end
