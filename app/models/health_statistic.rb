class HealthStatistic < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :measurements
end
