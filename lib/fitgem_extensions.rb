class Fitgem::Client
  def weight_on_date(date)
    get("/user/-/body/log/weight/date/#{format_date(date)}.json")
  end
  def fat_on_date(date)
    get("/user/-/body/log/fat/date/#{format_date(date)}.json")
#    get("/user/#{@user_id}/body/log/fat/date/#{format_date(date)}.json")
  end
  
  def daily_steps(date)
    get("/user/-/activities/tracker/steps/date/#{format_date(date)}/1d.json")
  end
end