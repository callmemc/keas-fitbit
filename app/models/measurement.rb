include MeasurementHelper

class Measurement < ActiveRecord::Base
  attr_accessible :health_statistic_id, :user_id, :seconds, :source, :value, :measured_at, :fb_collected_log_id
  belongs_to :user
  belongs_to :health_statistic
  belongs_to :fb_collected_log
  
  def self.create_activity(logItem, user_id, date, fb_log_id, source)
    name = logItem["name"]
    time = logItem["startTime"]
    resource = FitbitResource.find_by_name(name)
    stat = resource.health_statistic
    
    if stat.name == "walking"
      puts 'Creating Walking Measurement'
      Measurement.create(:user_id => user_id, :health_statistic_id => WALKING_ID, 
      :fb_collected_log_id => fb_log_id, :source => source, :value => logItem["steps"], 
      :seconds => logItem["duration"]/1000, :measured_at => datetime(date, time))
    end
  end
  
  def self.update_activity(logItem, date, fb_log_id)
    name = logItem["name"]
    resource = FitbitResource.find_by_name(name)
    stat = resource.health_statistic
        
    fb_log = FbCollectedLog.find(fb_log_id)
    m = fb_log.measurement
    if stat.name == "walking"
      puts 'Updating Walking Measurement'
      m.update_attributes(:value => logItem["steps"])
    end
  end

  def self.create_body_measurement(logItem, user_id, date, fb_log_id, resource)
    datetime = datetime(date, logItem["time"])
    if resource == FAT_ID
      puts 'Creating Fat Measurement'
      health_statistic_id = FAT_ID
      value = logItem["fat"]
    elsif resource == WEIGHT_ID
      puts 'Creating Weight Measurement' 
      health_statistic_id = WEIGHT_ID
      value = logItem["weight"]
    end
    Measurement.create(:user_id => user_id, :health_statistic_id => health_statistic_id, 
    :fb_collected_log_id => fb_log_id, :source => 'fitbit', :value => value, :measured_at => datetime)
  end
  
  def self.update_body_measurement(logItem, date, fb_log_id, resource)
    datetime = datetime(date, logItem["time"])
    fb_log = FbCollectedLog.find(fb_log_id)
    m = fb_log.measurement  
    if resource == FAT_ID
      puts 'Updating Fat Measurement'
      value = logItem["fat"]
    elsif resource == WEIGHT_ID
      puts 'Updating Weight Measurement' 
      value = logItem["weight"]
    end
    m.update_attributes(:value => value, :measured_at => datetime) # not sure if need to update datetime
  end
end
