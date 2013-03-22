class AddFbCollectedLogIdToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :fb_collected_log_id, :integer
  end
end
