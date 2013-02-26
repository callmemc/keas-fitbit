require 'pp'

class CollectController < ApplicationController  
  def create
    pp params[:updates]
    json_file = params[:updates].tempfile
    pp json_file
    #json_file = params[:updates].original_filename
    json_string = File.read(json_file)
    
    puts json_string

    parsed_json = ActiveSupport::JSON.decode(json_string)
      
    parsed_json.each do |notification|
      notification.symbolize_keys!      
      Notification.create(:collectionType => notification[:collectionType], :date => notification[:date], 
      :ownerId => notification[:ownerId], :ownerType => notification[:ownerType], 
      :subscriptionId => notification[:subscriptionId])
    end    
  end
end
