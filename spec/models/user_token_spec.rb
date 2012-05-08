require 'spec_helper'
require "fitgem/client"

describe UserToken do
    describe "testing basics" do
         before do
             @oa = {
                    :consumer_key => '82b31f0916944d2880bd07f1261d0f3d',
                    :consumer_secret => '55fb3407963e47f8a8c8f2b8f606f358',
                    :token => 'e7ed5916b0053db9d06bd6b29cbbd2a5',
                    :secret => '3094fc97cf7381ad819a95e69c61f33d',
                     :user_id => '22D339'
             }
             @client = Fitgem::Client.new(@oa)
             @access_token = @client.reconnect(@oa[:token], @oa[:secret])
         end
         it "Check output of user info" do
             @user_info = @client.user_info['user']
             p @user_info
             @user_info["gender"].should == "MALE"
             @user_info["dateOfBirth"].should == "1955-09-01"
         end
     end
end
