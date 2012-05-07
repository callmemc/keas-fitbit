require 'spec_helper'

describe "user_tokens/show" do
  before(:each) do
    @user_token = assign(:user_token, stub_model(UserToken,
      :user_id => 1,
      :request_token => "Request Token",
      :token => "Token",
      :secret => "Secret"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Request Token/)
    rendered.should match(/Token/)
    rendered.should match(/Secret/)
  end
end
