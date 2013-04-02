class FbCollectedLog < ActiveRecord::Base
  attr_accessible :logId, :user_id, :resource, :date
  belongs_to :user
  has_many :measurements
end
