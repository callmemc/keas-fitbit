require 'pp'

class NotificationController < ApplicationController  
  def create
    # Load the existing yml config
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
      exit
    end
    client = Fitgem::Client.new(config[:oauth])  #passed as hidden field
    
    pp params[:updates]
    json_file = params[:updates].tempfile
    json_string = File.read(json_file)

    parsed_json = ActiveSupport::JSON.decode(json_string)   
    
    #iterate through notifications within json file
    parsed_json.each do |notification|
      notification.symbolize_keys!      
      collectionType = notification[:collectionType]
      date = notification[:date]
      ownerId = notification[:ownerId]
      ownerType = notification[:ownerType]
      subscriptionId = notification[:subscriptionId]
      
      #Only looking up activities for now
      if (notification[:collectionType] == "activities")
        resource = 'activities'
        
        #Look up if existing ResourceCollection with resource_name and date
        resource_collection = ResourceCollection.where("resource_name = ? AND date = ?", resource, date).first
        
        
        #If collection for that day doesn't exist, create a new one
        if resource_collection.blank?
          resource_collection = ResourceCollection.create(:resource_name => resource, 
          :collected => Hash.new, :date => date)
        end
        
        activities = client.activities_on_date(date)["activities"]  #Array        
        #Need to edit to only take difference
        activities.each do |logItem|   #Each logItem is a Hash
          logId = logItem["logId"]
          if not resource_collection[:collected].has_key?(logId)     #if not already in collected,  
            resource_collection[:collected][logId] = logItem         #1) insert into hash, 
            if logItem["name"] == "Walking"                                                                  
              WalkingStatistic.create(:time => logItem["startTime"], #and 2) create statistic
              :date => date, :distance_in_miles => logItem["distance"])
            end
          end
        end
        
        resource_collection.save #SAVES changes to changed ResourceCollection!
      end      
    end
  end
end
