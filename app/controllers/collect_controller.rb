class CollectController < ApplicationController  
  def create
    if params[:collectionType]
      Notification.create(:collectionType => params[:collectionType], :date => params[:date], 
      :ownerId => params[:ownerId], :ownerType => params[:ownerType], 
      :subscriptionId => params[:subscriptionId])
    end
  end
end
