# If get subscription notification
# Go to resource URL
# For body: Update everything again
# For activities: Only update new activities (new activityId)


class FitbitController < ApplicationController
    # To change this template use File | Settings | File Templates.
    
    #Hardcoded, need to edit
    MY_CONSUMER_KEY = '537f25843e81488db9edf2f45c48e3d0'
    MY_CONSUMER_SECRET = '5db2d692a92c4a67bfa216de2be171ac'
    REQUEST_TOKEN_URL = 'http://api.fitbit.com/oauth/request_token'
    ACCESS_TOKEN_URL = 'http://api.fitbit.com/oauth/access_token'
    AUTHORIZE_URL = 'http://api.fitbit.com/oauth/authorize'
    
    def new
        client = Fitgem::Client.new(:consumer_key => MY_CONSUMER_KEY, :consumer_secret => MY_CONSUMER_SECRET)
        request_token = client.request_token
        u = UserToken.new
        u.request_token = request_token
        u.token = request_token.token
        u.secret = request_token.secret
        u.save
        @auth_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{u.token}"

        respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @dashboard }
        end
    end

    def init # We go here when Fitbit redirects back to us. Two params. oauth_token and oauth_verifier
        # We should have a record with the oauth_token in UserToken
        token = params["oauth_token"]
        verifier = params["oauth_verifier"]
        @user_token = UserToken.where(:token => token).first
        client = Fitgem::Client.new(:consumer_key => MY_CONSUMER_KEY, :consumer_secret => MY_CONSUMER_SECRET)
        access_token = client.authorize(@user_token.token, @user_token.secret, { :oauth_verifier => verifier })
        @user_token.final_secret = access_token.secret
        @user_token.final_token = access_token.token
        @user_token.save
        @user_data = client.user_info['user']
        respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @user_token }
        end
    end

=begin    
    def init # We go here when Fitbit redirects back to us. Two params. oauth_token and oauth_verifier
        # Load existing yml config
        config = begin
          Fitgem::Client.symbolize_keys(YAML.load(File.open(".fitgem.yml")))
        rescue ArgumentError => e
          puts "Could not parse YAML: #{e.message}"
          exit
        end
        client = Fitgem::Client.new(config[:oauth])
        
        # With the token and secret, we will try to use them
        # to reconstitute a usable Fitgem::Client
        if config[:oauth][:token] && config[:oauth][:secret]
          begin
            access_token = client.reconnect(config[:oauth][:token], config[:oauth][:secret])
          rescue Exception => e
            puts "Error: Could not reconnect Fitgem::Client due to invalid keys in .fitgem.yml"
            exit
          end
        # Without the secret and token, initialize the Fitgem::Client
        # and send the user to login and get a verifier token
        else
          request_token = client.request_token
          token = request_token.token
          secret = request_token.secret

          puts "Go to http://www.fitbit.com/oauth/authorize?oauth_token=#{token} and then enter the verifier code below"
          verifier = gets.chomp

          begin
            access_token = client.authorize(token, secret, { :oauth_verifier => verifier })
          rescue Exception => e
            puts "Error: Could not authorize Fitgem::Client with supplied oauth verifier"
            exit
          end

          puts 'Verifier is: '+verifier
          puts "Token is:    "+access_token.token
          puts "Secret is:   "+access_token.secret

          user_id = client.user_info['user']['encodedId']
          puts "Current User is: "+user_id

          config[:oauth].merge!(:token => access_token.token, :secret => access_token.secret, :user_id => user_id)

          # Write the whole oauth token set back to the config file
          File.open(".fitgem.yml", "w") {|f| f.write(config.to_yaml) }
        end

        
        # We should have a record with the oauth_token in UserToken
        #token = params["oauth_token"]
        #verifier = params["oauth_verifier"]
        #@user_token = UserToken.where(:token => token).first
        #client = Fitgem::Client.new(:consumer_key => MY_CONSUMER_KEY, :consumer_secret => MY_CONSUMER_SECRET)
        #access_token = client.authorize(@user_token.token, @user_token.secret, { :oauth_verifier => verifier })
        #@user_token.final_secret = access_token.secret
        #@user_token.final_token = access_token.token
        #@user_token.save
        #@user_data = client.user_info['user']
        
        create_subscription(:type => :body, :subscriptionId => :userId) # CREATING SUBSCRIPTION... using fitgem
                                        # subscriptionId = userId
        respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @user_token }
        end
    end
=end
    def show
        @client = basic_connect
        @user_info = @client.user_info['user']
        respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @user_token }
        end
    end    
    
    
end