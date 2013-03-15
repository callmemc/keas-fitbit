class Fitgem::Client
  def weight_on_date(date)
    get("/user/#{@user_id}/body/log/weight/date/#{format_date(date)}.json")
  end
  def fat_on_date(date)
    get("/user/#{@user_id}/body/log/fat/date/#{format_date(date)}.json")
  end  
end