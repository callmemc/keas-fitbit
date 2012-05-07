require 'spec_helper'

describe "user_tokens/index" do
  before(:each) do
    assign(:user_tokens, [
      stub_model(UserToken,
        :user_id => 1,
        :request_token => "Request Token",
        :token => "Token",
        :secret => "Secret"
      ),
      stub_model(UserToken,
        :user_id => 1,
        :request_token => "Request Token",
        :token => "Token",
        :secret => "Secret"
      )
    ])
  end

  it "renders a list of user_tokens" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Request Token".to_s, :count => 2
    assert_select "tr>td", :text => "Token".to_s, :count => 2
    assert_select "tr>td", :text => "Secret".to_s, :count => 2
  end
end
