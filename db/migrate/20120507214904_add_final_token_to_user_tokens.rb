class AddFinalTokenToUserTokens < ActiveRecord::Migration
  def change
    add_column :user_tokens, :final_token, :string
    add_column :user_tokens, :final_secret, :string
  end
end
