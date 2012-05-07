require 'spec_helper'

describe "user_tokens/new" do
  before(:each) do
    assign(:user_token, stub_model(UserToken,
      :user_id => 1,
      :request_token => "MyString",
      :token => "MyString",
      :secret => "MyString"
    ).as_new_record)
  end

  it "renders new user_token form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => user_tokens_path, :method => "post" do
      assert_select "input#user_token_user_id", :name => "user_token[user_id]"
      assert_select "input#user_token_request_token", :name => "user_token[request_token]"
      assert_select "input#user_token_token", :name => "user_token[token]"
      assert_select "input#user_token_secret", :name => "user_token[secret]"
    end
  end
end
