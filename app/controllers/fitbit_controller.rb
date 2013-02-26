#http://www.fitbitclient.com/guide/getting-started
#http://keas-fitbit.herokuapp.com/fitbit?oauth_token=c03f209de94008314375dfc3ec922340&oauth_verifier=mc51um9ohths7l80jb71h7513e

class FitbitController < ApplicationController
  
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

    config[:oauth].merge!(:token => access_token.token, :secret => access_token.secret, :user_id => user_id)

    # Write the whole oauth token set back to the config file
    File.open("config/fitgem.yml", "w") {|f| f.write(config.to_yaml) }
    
    #Create subscription using fitgem
    client.create_subscription(:type => :all, :subscription_id => user_id)  #one subscription per user
  end
  
  def authorize
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
    @client = Fitgem::Client.new(config[:oauth])  #passed as hidden field
    session[:client] = @client
    
    #Already have a FitBit account
    if config[:oauth][:token] && config[:oauth][:secret]
      @fitbit = true
    #Need to be directed to FitBit verify page
    else
      request_token = @client.request_token
      @token = request_token.token
      @secret = request_token.secret                                 
      @auth_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{@token}"
    end    
  end
  
  def verifier
    @verifier = params[:oauth_verifier]
  end
  
  def collect
    if params[:collectionType]
      Notification.create(:collectionType => params[:collectionType], :date => params[:date], 
      :ownerId => params[:ownerId], :ownerType => params[:ownerType], 
      :subscriptionId => params[:subscriptionId])
    end
  end
  
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
    if config[:oauth][:token] && config[:oauth][:secret]
      @fitbit = true
      begin
        access_token = client.reconnect(config[:oauth][:token], config[:oauth][:secret])
      rescue Exception => e
        puts "Error: Could not reconnect Fitgem::Client due to invalid keys in .fitgem.yml"
        exit
      end
      @subscriptions = client.subscriptions(:type => :all)
    #Provide link to Add FitBit
    else
      @fitbit = false
    end  
  end
 
end