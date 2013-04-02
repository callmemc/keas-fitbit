class FbCollectedLog < ActiveRecord::Base
  attr_accessible :logId, :user_id, :date
  belongs_to :user
  has_many :measurements
end
