class ConvertLogIdToFloat < ActiveRecord::Migration
  def up
    change_column :fb_collected_logs, :logId, :float #integer => float
  end

  def down
    change_column :fb_collected_logs, :logId, :integer
  end
end
