class CollectController < ApplicationController  
  def create
    json_string = params[:updates]
    parsed_json = ActiveSupport::JSON.decode(json_string)
    
    
    parsed_json.each do |notification|      
      Notification.create(:collectionType => notification[:collectionType], :date => notification[:date], 
      :ownerId => notification[:ownerId], :ownerType => notification[:ownerType], 
      :subscriptionId => notification[:subscriptionId])
    end    
  end
end
