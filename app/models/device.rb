class Device < ActiveRecord::Base
  attr_accessible :name, :user_id, :token, :secret, :owner_id
  belongs_to :user
  has_many :fb_collected_logs
end
