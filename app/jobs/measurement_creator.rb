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

    # ================= GETTING RESOURCES =================== #    
    if collectionType == 'activities'
      log = client.activities_on_date(date)["activities"]
      puts 'Activities Log'
      puts log     
      log.each do |logItem|   #Each logItem is a Hash
        logId = logItem["logId"]
        collected_logs = user.fb_collected_logs
        if collected_logs == [] || collected_logs.find_by_logId(logId) == nil
          fb_log = FbCollectedLog.create(:user_id => user.id, :logId => logId)
          m = Measurement.create_activity(logItem, fitbit_device.user_id, date, fb_log.id)
        end
      end
    elsif collectionType == 'body'
      fat_log = client.fat_on_date(date)["fat"]      
      puts 'Fat Log'
      pp fat_log      
      weight_log = client.weight_on_date(date)["weight"]
      puts 'Weight Log'
      pp weight_log
                       
      fat_log.each do |fatItem|
        logId = fatItem["logId"]  # shares log Id with weightItem
        collected_logs = user.fb_collected_logs
        if collected_logs == [] || collected_logs.find_by_logId(logId) == nil
          puts 'if'
          fb_log = FbCollectedLog.create(:user_id => user.id, :logId => logId)
          puts 'calling create'
          m = Measurement.create_body_measurements(fatItem, weightItem, fitbit_device.user_id, date, fb_log.id)
        else
          puts 'else'
          fb_log = user.fb_collected_logs.find_by_logId(logId)
          puts 'calling update'
          m = Measurement.update_body_measurements(fatItem, weightItem, date, fb_log.id)
        end
      end
      
      weight_log.each do |weightItem|
        logId = weightItem["logId"]  # shares log Id with weightItem
        collected_logs = user.fb_collected_logs
        if collected_logs == [] || collected_logs.find_by_logId(logId) == nil
          puts 'if'
          fb_log = FbCollectedLog.create(:user_id => user.id, :logId => logId)
          puts 'calling create'
          m = Measurement.create_body_measurements(fatItem, weightItem, fitbit_device.user_id, date, fb_log.id)
        else
          puts 'else'
          fb_log = user.fb_collected_logs.find_by_logId(logId)
          puts 'calling update'
          m = Measurement.update_body_measurements(fatItem, weightItem, date, fb_log.id)
        end
      end
            
    end     
  end
end