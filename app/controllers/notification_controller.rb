require 'pp'

# After receiving notification from FitBit subscription, need to create Keas HealthStatistic
class NotificationController < ApplicationController  
  def create
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
      
      # Enqueue notification hash
      Resque.enqueue(MeasurementCreator, {:collectionType => collectionType, :date => date,
        :ownerId => ownerId, :ownerType => ownerType, :subscriptionId => subscriptionId})

    end
  end
end
