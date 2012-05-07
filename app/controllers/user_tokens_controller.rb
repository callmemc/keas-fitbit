class UserTokensController < ApplicationController
  # GET /user_tokens
  # GET /user_tokens.json
  def index
    @user_tokens = UserToken.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_tokens }
    end
  end

  def init
      #Here when Fitbit redirects back to us
      logger.debug "Killroy was here"
      @params = params
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user_token }
      end
  end

  # GET /user_tokens/1
  # GET /user_tokens/1.json
  def show
    @user_token = UserToken.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_token }
    end
  end

  MY_CONSUMER_KEY = '82b31f0916944d2880bd07f1261d0f3d'
  MY_CONSUMER_SECRET = '55fb3407963e47f8a8c8f2b8f606f358'
  REQUEST_TOKEN_URL = 'http://api.fitbit.com/oauth/request_token'
  ACCESS_TOKEN_URL = 'http://api.fitbit.com/oauth/access_token'
  AUTHORIZE_URL = 'http://api.fitbit.com/oauth/authorize'

  # GET /user_tokens/new
  # GET /user_tokens/new.json
  def new
      @user_token = UserToken.new
      client = Fitgem::Client.new(:consumer_key => MY_CONSUMER_KEY, :consumer_secret => MY_CONSUMER_SECRET)
      request_token = client.request_token
      @user_token.request_token = request_token
      @user_token.token = request_token.token
      @user_token.secret = request_token.secret
      @user_token.save
      @auth_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{@user_token.token}"

      respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @dashboard }
      end
  end

  # GET /user_tokens/1/edit
  def edit
    @user_token = UserToken.find(params[:id])
  end

  # POST /user_tokens
  # POST /user_tokens.json
  def create
    @user_token = UserToken.new(params[:user_token])

    respond_to do |format|
      if @user_token.save
        format.html { redirect_to @user_token, notice: 'User token was successfully created.' }
        format.json { render json: @user_token, status: :created, location: @user_token }
      else
        format.html { render action: "new" }
        format.json { render json: @user_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_tokens/1
  # PUT /user_tokens/1.json
  def update
    @user_token = UserToken.find(params[:id])

    respond_to do |format|
      if @user_token.update_attributes(params[:user_token])
        format.html { redirect_to @user_token, notice: 'User token was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_tokens/1
  # DELETE /user_tokens/1.json
  def destroy
    @user_token = UserToken.find(params[:id])
    @user_token.destroy

    respond_to do |format|
      format.html { redirect_to user_tokens_url }
      format.json { head :ok }
    end
  end
end
