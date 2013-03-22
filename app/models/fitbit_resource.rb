class FitbitResource < ActiveRecord::Base
  attr_accessible :name, :health_statistic_id
  
  belongs_to :health_statistic
end
