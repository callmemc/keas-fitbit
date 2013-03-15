require 'pp'
class MeasurementCreator  
  @queue = :notifications
  
  def self.perform(notification_id)
    notification = Notification.find(notification_id)
    date = notification[:date]
    ownerId = notification[:ownerId]
    resource = notification[:collectionType]
       
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
    fitbit_device = Device.where("name = ? AND owner_id = ?", 'fitbit', ownerId).first  #Assumes there's only one device
    client = Fitgem::Client.new(:consumer_key => consumer_key, :consumer_secret => consumer_secret, :token => fitbit_device[:token], :secret => fitbit_device[:secret])

    # Look up if existing ResourceCollection with resource_name and date
    resource_collection = fitbit_device.resource_collections.where("resource_name = ? AND date = ?", resource, date).first
    # If collection for that day doesn't exist, create a new one
    if resource_collection.blank?
      resource_collection = ResourceCollection.create(:device_id => fitbit_device.id, :resource_name => resource, 
      :date => date, :collected => Hash.new)
    end

    # ================= GETTING RESOURCES =================== #    
    if resource == 'activities'        
      log = client.activities_on_date(date)["activities"]  #Array
      log.each do |logItem|   #Each logItem is a Hash
        logId = logItem["logId"]
#        if not resource_collection[:collected].has_key?(logId)                  # if not already in collected,  
#          resource_collection[:collected][logId] = logItem                         # insert into hash
        if logItem["name"] == "Walking"
          puts 'Creating Walking Measurement'
          m = Measurement.where("health_statistic_id = ?", WALKING_ID).find_or_initialize_by_logId(logId)
          m.update_attributes(:user_id => fitbit_device.user_id, :health_statistic_id => WALKING_ID, 
          :source => 'fitbit', :value => logItem["steps"], :seconds => logItem["duration"]/1000)    
        end
#        end
      end
    elsif resource == 'body'
      puts 'Body Resource'

      fat_log = client.fat_on_date(date)["fat"]      
      puts 'Fat Log'
      pp fat_log
      
      weight_log = client.weight_on_date(date)["weight"]
      puts 'Weight Log'
      pp weight_log
            
      # ***Fat and Log logged together under one log ID
      fat_log.zip(weight_log).each do |fatItem, weightItem|
        logId = fatItem["logId"] # = weightItem["logId"] as well
#        if not resource_collection[:collected].has_key?(logId)              
#        resource_collection[:collected][logId] = true
        
        fatm = Measurement.where("health_statistic_id = ?", FAT_ID).find_or_initialize_by_logId(logId)  
        puts 'Creating or updating Fat Measurement'
        fatm.update_attributes(:logId => logId, :user_id => fitbit_device.user_id, :health_statistic_id => FAT_ID, 
        :source => 'fitbit', :value => fatItem["fat"])
        
        puts 'Creating or updating Weight Measurement'
        weightm = Measurement.where("health_statistic_id = ?", WEIGHT_ID).find_or_initialize_by_logId(logId) 
        weightm.update_attributes(:logId => logId, :user_id => fitbit_device.user_id, :health_statistic_id => WEIGHT_ID, 
        :source => 'fitbit', :value => weightItem["weight"])    
#        end      
      end      
    end
        
    resource_collection.save # SAVES changes to changed ResourceCollection!
    
  end
end