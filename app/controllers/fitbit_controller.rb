class FitbitController < ApplicationController

=begin  
  #Authorizes Fitgem::Client with verifier entered by user
  #Creates a FitBit device
  def create
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
    
    client = session[:client]
    token = params[:token]
    secret = params[:secret]
    verifier = params[:verifier]
        
    begin
      access_token = client.authorize(token, secret, { :oauth_verifier => verifier })
    rescue Exception => e
      puts "Error: Could not authorize Fitgem::Client with supplied oauth verifier: " + verifier
      exit
    end

    user_id = client.user_info['user']['encodedId']

    #:owner_id => user_id might be a bit confusing
    device = Device.create(:name => 'fitbit', :user_id => current_user.id, :owner_id => user_id, 
    :token => access_token.token, :secret => access_token.secret )
        
    #Create subscription using fitgem
    client.create_subscription(:type => :all, :subscription_id => user_id)  #one subscription per user fix!!!
    
    respond_to do |format|
      format.html { redirect_to '/fitbit' }
    end
  end
=end
  
  #Displays link to authorize FitBit account and field to enter verifier
  def authorize
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
    client = Fitgem::Client.new(config[:oauth])  #passed as hidden field
#    session[:client] = @client
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
      
      config = begin
        Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
      rescue ArgumentError => e
        puts "Could not parse YAML: #{e.message}"
        exit
      end
      
      client = Fitgem::Client.new(config[:oauth]) 
      
      begin
        access_token = client.authorize(token, secret, { :oauth_verifier => verifier })
      rescue Exception => e
        @error = true
        puts "Error: Could not authorize Fitgem::Client with supplied oauth verifier: " + verifier
        # exit
      end
      user_id = client.user_info['user']['encodedId']
      user = request_token.user

      #:owner_id => user_id might be a bit confusing
      device = Device.create(:name => 'fitbit', :user_id => user.id, :owner_id => user_id, 
      :token => access_token.token, :secret => access_token.secret )

      #Create subscription using fitgem
      client.create_subscription(:type => :all, :subscription_id => user_id)  #one subscription per user fix!!!      
    end
  end
    
  def remove_sub
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
    
    client = Fitgem::Client.new(config[:oauth])    
    client.remove_subscriptions(:type => :all, :subscription_id => "24N6YJ", :subscriber_id => "1")    
  end
   
  # Displays notifications
  def index 
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
    
    client = Fitgem::Client.new(config[:oauth])  
    # With USER CREDENTIALS token and secret, try to use them to reconstitute a usable Fitgem::Client
    # Then display subscription info
    
    if current_user
      if fitbit_device = current_user.devices.where("name = ?", 'fitbit').first #found device
        @fitbit = true
        begin
          access_token = client.reconnect(fitbit_device[:token], fitbit_device[:secret])
        rescue Exception => e
          puts "Error: Could not reconnect Fitgem::Client due to invalid token and secret in device"
          exit
        end
        @subscriptions = client.subscriptions(:type => :all)
      #Provide link to Add FitBit
      else
        @fitbit = false
      end
    end
    
    @walking_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WALKING_ID, current_user)
    puts 'walking measurements'
    puts @walking_measurements
    @total_steps = @walking_measurements.sum(&:value)
    @total_seconds = @walking_measurements.sum(&:seconds)
    
    @fat_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", FAT_ID, current_user)
    @weight_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WEIGHT_ID, current_user)
  end
 
end