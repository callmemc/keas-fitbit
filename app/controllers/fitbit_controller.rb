class FitbitController < ApplicationController

  #Displays link to authorize FitBit account and field to enter verifier
  def authorize   
    client = initialize_client
    
    request_token = client.request_token
    token = request_token.token
    secret = request_token.secret    
    RequestToken.create(:token => token, :secret => secret, :user_id => current_user.id)
    @auth_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{token}" #URL to authorize Keas with FitBit 
  end
  
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

      #Create subscription using fitgem
      if client.subscriptions(:type => :all) == {}
        client.create_subscription(:type => :all, :subscription_id => owner_id)  #one subscription per user
      end
    end
  end
    
  def remove_sub
    client = initialize_client   
    client.remove_subscriptions(:type => :all, :subscription_id => "24N6YJ", :subscriber_id => "1")    
  end
   
  # Displays notifications
  def index     
    # With USER CREDENTIALS token and secret, try to use them to reconstitute a usable Fitgem::Client
    if current_user
      if fitbit_device = current_user.devices.where("name = ?", 'fitbit').first #found device
        @fitbit = true
      end
    end
    
    @walking_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WALKING_ID, current_user)
    @total_steps = @walking_measurements.sum(&:value)
    @total_seconds = @walking_measurements.sum(&:seconds)
    
    @fat_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", FAT_ID, current_user)
    @weight_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WEIGHT_ID, current_user)
  end
  
  # Load the existing yml config and use consumer key/secret to initialize new Fitgem client
  def initialize_client
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
    end
    
    return Fitgem::Client.new(config[:oauth])  # new client
  end
  
  def reconnect_client
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
    end
    
    return Fitgem::Client.new(config[:oauth])  # new client
  end
 
end