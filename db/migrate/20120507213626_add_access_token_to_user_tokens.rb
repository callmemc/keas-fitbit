class AddAccessTokenToUserTokens < ActiveRecord::Migration
  def change
    add_column :user_tokens, :access_token, :string
  end
end
