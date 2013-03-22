class CreateFitbitCollectedIds < ActiveRecord::Migration
  def change
    create_table :fitbit_collected_ids do |t|
      t.integer :logId
      t.integer :device_id

      t.timestamps
    end
  end
end
