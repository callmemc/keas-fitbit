include ClientHelper

class FitbitController < ApplicationController

  #After authorizing FitBit, user is given verifier code on this page that it must enter in authorize page
  def verifier
    token = params[:oauth_token]  #request token
    verifier = params[:oauth_verifier]
    if RequestToken.where("token = ?", token).first == nil
      @error = true
    else
      request_token = RequestToken.where("token = ?", token).first
      secret = request_token[:secret]
  
      client = initialize_client      
      begin
        access_token = client.authorize(token, secret, { :oauth_verifier => verifier })
      rescue Exception => e
        @error = true
        puts "Error: Could not authorize Fitgem::Client with supplied oauth verifier: " + verifier
      end
      
      owner_id = client.user_info['user']['encodedId']
      user = request_token.user
      device = Device.create(:name => 'fitbit', :user_id => user.id, :owner_id => owner_id, 
      :token => access_token.token, :secret => access_token.secret )

      #Create only one subscription using fitgem
      if client.subscriptions(:type => :all) == {}
        client.create_subscription(:type => :all, :subscription_id => owner_id)  #one subscription per user
      end
    end
  end
   
  # Displays notifications
  def index     
    # With USER CREDENTIALS token and secret, try to use them to reconstitute a usable Fitgem::Client
    if current_user
      if fitbit_device = current_user.devices.where("name = ?", 'fitbit').first #found device
        @fitbit = true
#SUBSCRIPTIONS/CLIENT TESTING
        client = reconnect_client(fitbit_device[:token], fitbit_device[:secret])                
        subscriptions = client.subscriptions(:type => :all)
        print 'subscriptions: '
        puts subscriptions
        
        @walking_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WALKING_ID, current_user)
        @total_steps = @walking_measurements.sum(&:value)
        @total_seconds = @walking_measurements.sum(&:seconds)
        @fat_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", FAT_ID, current_user)
        @weight_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WEIGHT_ID, current_user)
      else
        client = initialize_client
        request_token = client.request_token
        token = request_token.token
        secret = request_token.secret    
        RequestToken.create(:token => token, :secret => secret, :user_id => current_user.id)
        @auth_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{token}" #URL to authorize Keas with FitBit
      end
    end
  end
  
  def remove_sub
    client = initialize_client   
    client.remove_subscriptions(:type => :all, :subscription_id => "24N6YJ", :subscriber_id => "1")    
  end

end