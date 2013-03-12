class Measurement < ActiveRecord::Base
  attr_accessible :health_statistic_id, :user_id, :seconds, :source, :value
  belongs_to :user
  belongs_to :health_statistic
end
