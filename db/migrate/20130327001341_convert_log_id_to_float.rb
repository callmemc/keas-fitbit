class ConvertLogIdToFloat < ActiveRecord::Migration
  def change
    change_column :fb_collected_logs, :logId, :float #integer => float
  end
end
