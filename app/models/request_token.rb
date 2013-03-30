class RequestToken < ActiveRecord::Base
  attr_accessible :secret, :token, :user_id  
  belongs_to :user
end
