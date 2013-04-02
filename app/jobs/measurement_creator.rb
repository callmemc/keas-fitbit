require 'pp'
include ClientHelper

class MeasurementCreator  
  @queue = :notifications
  
  def self.perform(notification)
    pp notification  
    date = notification["date"]
    ownerId = notification["ownerId"]
    collectionType = notification["collectionType"]

    fitbit_device = Device.where("name = ? AND owner_id = ?", 'fitbit', ownerId).first
    if fitbit_device == nil
      puts "Notification can't be processed: Fitbit account not attached to any keas user"
      return
    end
    
    client = reconnect_client(fitbit_device[:token], fitbit_device[:secret])
    user = fitbit_device.user
    collected_logs = user.fb_collected_logs

    # ================= GETTING ACTIVITIES RESOURCES =================== #    
    if collectionType == 'activities'
      log = client.activities_on_date(date)["activities"]
      puts 'Activities Log'
      puts log     
      # Update Logged Activity
      log.each do |logItem|   #Each logItem is a Hash
        logId = logItem["logId"]
        if collected_logs == [] || collected_logs.find_by_logId(logId) == nil
          fb_log = FbCollectedLog.create(:user_id => user.id, :logId => logId)
          m = Measurement.create_activity(logItem, fitbit_device.user_id, date, fb_log.id, 'fitbit log')
        end
      end
      # Update Tracker Activity
      daily_steps = client.daily_steps(date)["activities-tracker-steps"][0]["value"]
      if daily_steps != 0
        logItem = {"name" => "Walking", "startTime" => "00:00", "steps" => daily_steps, "duration" => 0}
        if collected_logs == [] || collected_logs.find_by_date(date) == nil
          fb_log = FbCollectedLog.create(:user_id => user.id, :date => date)
          m = Measurement.create_activity(logItem, fitbit_device.user_id, date, fb_log.id, 'fitbit tracker')
        else
          fb_log = user.fb_collected_logs.find_by_date(date)
          m = Measurement.update_activity(logItem, date, fb_log.id)
        end        
      end
    # ================= GETTING BODY RESOURCES =================== #    
    elsif collectionType == 'body'
      fat_log = client.fat_on_date(date)["fat"]      
      puts 'Fat Log'
      pp fat_log      
      weight_log = client.weight_on_date(date)["weight"]
      puts 'Weight Log'
      pp weight_log

      arr = [{:resource => FAT_ID, :log => fat_log}, {:resource => WEIGHT_ID, :log => weight_log}]
      arr.each do |i|
        resource = i[:resource]
        log = i[:log]
        log.each do |logItem|
          logId = logItem["logId"]
          if collected_logs == [] || collected_logs.where("resource = ?", resource).find_by_logId(logId) == nil
            fb_log = FbCollectedLog.create(:user_id => user.id, :logId => logId, :resource => resource)
            m = Measurement.create_body_measurement(logItem, fitbit_device.user_id, date, fb_log.id, resource)
          else
            fb_log = collected_logs.where("resource = ?", resource).find_by_logId(logId)
            m = Measurement.update_body_measurement(logItem, date, fb_log.id, resource)
          end
        end
      end
    end     
  end
end