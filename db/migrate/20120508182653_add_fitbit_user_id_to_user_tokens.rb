class AddFitbitUserIdToUserTokens < ActiveRecord::Migration
  def change
    add_column :user_tokens, :fitbit_user_id, :string
  end
end
