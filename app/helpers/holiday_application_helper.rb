module HolidayApplicationHelper

  def start_date_name
    if @holiday_application.working_type == 'on_holiday_working'
      '出勤日'
    elsif @holiday_application.one_day_application?
      '対象日'
    else
      getLongName('holiday_applications','start_date')
    end
  end

end
