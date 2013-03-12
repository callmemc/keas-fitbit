class CreateHealthStatistics < ActiveRecord::Migration
  def change
    create_table :health_statistics do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
