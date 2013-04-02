class FbCollectedLog < ActiveRecord::Base
  attr_accessible :logId, :user_id, :resource
  belongs_to :user
  has_many :measurements
end
