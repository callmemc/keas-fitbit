class HealthStatistic < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :measurements
  
  has_one :fitbit_resource
end
