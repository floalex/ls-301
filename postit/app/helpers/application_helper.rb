module ApplicationHelper
  def fix_url(link)
    link.starts_with?('http://') ? link : "http://#{link}"
  end
  
  def display_datetime(time)
    time.strftime("%m/%d/%y %I:%M%P %Z") #month/day/year 10:30PM timezone
  end
end
