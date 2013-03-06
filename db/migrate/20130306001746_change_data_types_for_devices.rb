class ChangeDataTypesForDevices < ActiveRecord::Migration
  def up
    change_table :devices do |t|
      t.change :user_id, :integer
    end
  end

  def down
    change_table :devices do |t|
      t.change :user_id, :string
    end
  end
end
