class Device < ActiveRecord::Base
  attr_accessible :type, :user_id, :token, :secret
end
