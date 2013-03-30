include ClientHelper

class FitbitController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :remove_fitbit_account]
   
  def index     
    if fitbit_device = current_user.devices.where("name = ?", 'fitbit').first
      @fitbit = true
      @fitbit_url = "http://www.fitbit.com/user/#{fitbit_device[:owner_id]}" 
     client = reconnect_client(fitbit_device[:token], fitbit_device[:secret])                
      puts client.subscriptions(:type => :all)
    else
      client = initialize_client
      request_token = client.request_token
      token = request_token.token
      secret = request_token.secret
      RequestToken.create(:token => token, :secret => secret, :user_id => current_user.id)
      @auth_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{token}" #URL to authorize Keas with FitBit
    end
  end
  
  def add_fitbit_account
    token = params[:oauth_token]  #request token
    verifier = params[:oauth_verifier]
    client = initialize_client
    request_token = RequestToken.where("token = ?", token).first
    
    if request_token == nil
      @error = true
    else
      access_token = authorize_client(client, token, verifier, request_token)
      if access_token == false
        @error = true
      else
        owner_id = client.user_info['user']['encodedId']
        user = request_token.user        
        user.request_tokens.destroy_all   #delete_all doesn't work? how come it works in console...
        # create device
        device = Device.create(:name => 'fitbit', :user_id => user.id, :owner_id => owner_id, 
        :token => access_token.token, :secret => access_token.secret)
        # create subscription
        client.create_subscription(:type => :all, :subscription_id => owner_id)  #one subscription per user
      end
    end
  end
  
  def remove_fitbit_account
    fitbit_device = current_user.devices.where("name = ?", 'fitbit').first
    client = reconnect_client(fitbit_device[:token], fitbit_device[:secret]) 
    #remove subscription to Fitbit for this account
    client.remove_subscription(:type => :all, :subscription_id => fitbit_device[:owner_id], :subscriber_id => "1")
    #delete device
    Device.delete(fitbit_device.id)

    respond_to do |format|
      format.html { redirect_to '/fitbit' }
    end
  end
end