=begin
require 'pp'

# After receiving notification from FitBit subscription, need to create Keas HealthStatistic
class NotificationController < ApplicationController  
  def create
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end

    json_file = params[:updates].tempfile
    json_string = File.read(json_file)
    parsed_json = ActiveSupport::JSON.decode(json_string)       
    # Iterate through notifications within json file
    parsed_json.each do |notification|
      notification.symbolize_keys!      
      collectionType = notification[:collectionType]
      date = notification[:date]
      ownerId = notification[:ownerId]
      ownerType = notification[:ownerType]
      subscriptionId = notification[:subscriptionId]
      
      # Create notification item to be enqueued
      notification = Notification.create(:collectionType => collectionType, :date => date, 
      :ownerId => ownerId, :ownerType => ownerType, :subscriptionId => subscriptionId)
      # Enqueue Notification
  puts notification
      Resqueue.enqueue(StatisticCreator, notification.id)
      
      # Only looking up activities for now
      if (notification[:collectionType] == "activities")
        resource = 'activities'
        
        # Need to initialize new FitBit client for every notification
        consumer_key = config[:oauth][:consumer_key]
        consumer_secret = config[:oauth][:consumer_secret]
        fitbit_device = Device.where("name = ? AND owner_id = ?", 'fitbit', ownerId).first  #Assumes there's only one device
        client = Fitgem::Client.new(:consumer_key => consumer_key, 
        :consumer_secret => consumer_secret,
        :token => fitbit_device[:token], 
        :secret => fitbit_device[:secret])
        
        # Look up if existing ResourceCollection with resource_name and date
        resource_collection = fitbit_device.resource_collections.where("resource_name = ? AND date = ?", resource, date).first               
        # If collection for that day doesn't exist, create a new one
        if resource_collection.blank?
          resource_collection = ResourceCollection.create(:device_id => fitbit_device.id, :resource_name => resource, 
          :date => date, :collected => Hash.new)
        end

#EXTERNAL REQUEST        
        activities = client.activities_on_date(date)["activities"]  #Array        
        # Need to edit to only take difference
        activities.each do |logItem|   #Each logItem is a Hash
          logId = logItem["logId"]
          if not resource_collection[:collected].has_key?(logId)     #if not already in collected,  
            resource_collection[:collected][logId] = logItem         #1) insert into hash, 
            if logItem["name"] == "Walking"                                                                  
              WalkingStatistic.create(:user_id => fitbit_device.user_id, #and 2) create statistic
              :time => logItem["startTime"], :date => date, :distance_in_miles => logItem["distance"])
            end
          end
        end
        
        resource_collection.save # SAVES changes to changed ResourceCollection!
      end      
    end
  end
end
=end
