module MeasurementHelper
  # creates a DateTime object out of date and time strings
  def datetime (date, time)
    dt = date + "T" + time
    return DateTime.strptime(dt,'%Y-%m-%dT%H:%M')
  end
end
