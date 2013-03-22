class CreateFitbitResources < ActiveRecord::Migration
  def change
    create_table :fitbit_resources do |t|
      t.string :name
      t.integer :health_statistic_id

      t.timestamps
    end
  end
end
