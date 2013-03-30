class PagesController  < ApplicationController
  before_filter :authenticate_user!, :only => [:profile]
  
  def home
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def profile
    @walking_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WALKING_ID, current_user)
    @total_steps = @walking_measurements.sum(&:value)
    @total_seconds = @walking_measurements.sum(&:seconds)
    @fat_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", FAT_ID, current_user)
    @weight_measurements = Measurement.where("health_statistic_id = ? AND user_id = ?", WEIGHT_ID, current_user)    
  end
end