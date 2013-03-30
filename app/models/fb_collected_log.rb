class FbCollectedLog < ActiveRecord::Base
  attr_accessible :logId, :user_id
  belongs_to :user
  has_many :measurements
end
