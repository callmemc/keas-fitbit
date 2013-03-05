class WalkingStatistic < ActiveRecord::Base  #inherits from Health Statistic
  attr_accessible :distance_in_miles, :date, :time
  
end
