include MeasurementHelper

class Measurement < ActiveRecord::Base
  attr_accessible :health_statistic_id, :user_id, :seconds, :source, :value, :measured_at, :fb_collected_log_id
  belongs_to :user
  belongs_to :health_statistic
  belongs_to :fb_collected_log
  
  def self.create_activity(logItem, user_id, date, fb_log_id)
puts 'invoking create activity'

    name = logItem["name"]
    time = logItem["startTime"]
    resource = FitbitResource.find_by_name(name)
    stat = resource.health_statistic
    
    if stat.name == "walking"
      puts 'Creating Walking Measurement'
      Measurement.create(:user_id => user_id, :health_statistic_id => WALKING_ID, 
      :fb_collected_log_id => fb_log_id, :source => 'fitbit', :value => logItem["steps"], 
      :seconds => logItem["duration"]/1000, :measured_at => datetime(date, time))
    end  
  end
  
  def self.create_body_measurements(fatItem, weightItem, user_id, date, fb_log_id)
    datetime = datetime(date, fatItem["time"])
    
    #fat item
    puts 'Creating Fat & Weight Measurements'
    Measurement.create(:user_id => user_id, :health_statistic_id => FAT_ID, 
    :fb_collected_log_id => fb_log_id, :source => 'fitbit', 
    :value => fatItem["fat"], :measured_at => datetime)
    #weight item
    Measurement.create(:user_id => user_id, :health_statistic_id => WEIGHT_ID, 
    :fb_collected_log_id => fb_log_id, :source => 'fitbit', 
    :value => weightItem["weight"], :measured_at => datetime)
  end
  
  def self.update_body_measurements(fatItem, weightItem, date, fb_log_id)
    datetime = datetime(date, fatItem["time"])    
    fb_log = FbCollectedLog.find(fb_log_id)
    fatm = fb_log.measurements.where("health_statistic_id = ?", FAT_ID).first
    weightm = fb_log.measurements.where("health_statistic_id = ?", WEIGHT_ID).first
    
    #UPDATING ATTRIBUTES
    puts 'Updating Fat & Weight Measurements'
    fatm.update_attributes(:value => fatItem["fat"], :measured_at => datetime)
    weightm.update_attributes(:value => weightItem["weight"], :measured_at => datetime)
  end
end
