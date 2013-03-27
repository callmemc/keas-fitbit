require 'pp'
class MeasurementCreator  
  @queue = :notifications
  
  def self.perform(notification)
    pp notification
    
    date = notification["date"]
    ownerId = notification["ownerId"]
    collectionType = notification["collectionType"]
    
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
        
    #Initialize new FitBit client for current_user
    consumer_key = config[:oauth][:consumer_key]
    consumer_secret = config[:oauth][:consumer_secret]
    fitbit_device = Device.where("name = ? AND owner_id = ?", 'fitbit', ownerId).first
    
puts 'fibit_device id'
puts fitbit_device.id
    
    client = Fitgem::Client.new(:consumer_key => consumer_key, :consumer_secret => consumer_secret, :token => fitbit_device[:token], :secret => fitbit_device[:secret])

    # ================= GETTING RESOURCES =================== #    
    if collectionType == 'activities'
      log = client.activities_on_date(date)["activities"]
      puts 'Activities Log'
      puts log     
      log.each do |logItem|   #Each logItem is a Hash
        logId = logItem["logId"]
        if fitbit_device.fb_collected_logs == [] || fitbit_device.fb_collected_logs.find_by_logId(logId) == nil #log only things not yet collected
          fb_log = FbCollectedLog.create(:device_id => fitbit_device.id, :logId => logId) #CHECK
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
            
      fat_log.zip(weight_log).each do |fatItem, weightItem|
        logId = fatItem["logId"]  # shares log Id with weightItem
         if fitbit_device.fb_collected_logs == [] || fitbit_device.fb_collected_logs.find_by_logId(logId) == nil #log only things not yet collected
          fb_log = FbCollectedLog.create(:device_id => fitbit_device.id, :logId => logId)
          m = Measurement.create_body_measurements(fatItem, weightItem, fitbit_device.user_id, date, fb_log.id)
        else
          fb_log = fitbit_device.fb_collected_logs.find_by_logId(logId)
          m = Measurement.update_body_measurements(fatItem, weightItem, date, fb_log.id)
        end
      end      
    end
            
  end
end