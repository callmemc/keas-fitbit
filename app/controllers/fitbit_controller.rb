class FitbitController < ApplicationController
    # To change this template use File | Settings | File Templates.

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
end