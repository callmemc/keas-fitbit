class AddDateToFbCollectedLogs < ActiveRecord::Migration
  def change
    add_column :fb_collected_logs, :date, :string
  end
end
