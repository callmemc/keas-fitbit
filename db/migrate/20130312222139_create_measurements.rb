class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.string :source
      t.decimal :value
      t.integer :seconds
      t.integer :user_id
      t.integer :health_statistic_id

      t.timestamps
    end
  end
end
