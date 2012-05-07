class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.integer :user_id
      t.string :request_token
      t.string :token
      t.string :secret

      t.timestamps
    end
  end
end
