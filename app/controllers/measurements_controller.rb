class MeasurementsController  < ApplicationController

=begin
  def self.create_from_log(logItem)
    puts 'create_from_log invoked'
    
    name = logItem["name"]
    resource = FitbitResource.find_by_name(name)
    stat = resource.health_statistic
    
    if health_statistic.name == "Walking"
      puts 'Creating Walking Measurement'
      Measurement.create(:user_id => fitbit_device.user_id, :health_statistic_id => WALKING_ID, 
      :source => 'fitbit', :value => logItem["steps"], :seconds => logItem["duration"]/1000)
    end  
  end
=end

end