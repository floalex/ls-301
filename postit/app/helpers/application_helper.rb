module ApplicationHelper
  def fix_url(link)
    link.starts_with?('http://') ? link : "http://#{link}"
  end
  
  def display_datetime(time)
    time.strftime("%m/%d/%y %I:%M%P %Z") #month/day/year 10:30PM timezone
  end
  
  def ajax_flash(div_id)
    response = ""
    flash_div = ""

    flash.each do |name, msg|
      if msg.is_a?(String)
        flash_div = "<div class=\"alert alert-#{name == :notice ? 'success' : 'error'} ajax_flash\"><a class=\"close\" data-dismiss=\"alert\">&#215;</a> <div id=\"flash_#{name == :notice ? 'notice' : 'error'}\">#{msg}</div> </div>"
      end 
    end
    
    response = "$('.ajax_flash').remove();$('#{div_id}').prepend('#{flash_div}');"
    response.html_safe
  end
end
