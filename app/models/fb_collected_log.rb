class FbCollectedLog < ActiveRecord::Base
  attr_accessible :logId, :device_id
  belongs_to :device
  has_many :measurements
end
