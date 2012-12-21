module MonthlyWorkingHelper
  include DateTimeUtil

  def title_map
    {
      'total_working_hour' => '月総労働時間一覧',
      'total_negative_hour' => '総超過労働時間一覧',
      'total_latearly_count' => '遅刻・早退一覧',
      'total_vacation_count' => '休暇取得状況一覧',
      'working_time_sheet' => '勤務表'
    }
  end

  def total_working_hour?
    controller.action_name == 'total_working_hour'
  end
  def total_negative_hour?
    controller.action_name == 'total_negative_hour'
  end
  def total_latearly_count?
    controller.action_name == 'total_latearly_count'
  end
  def total_vacation_count?
    controller.action_name == 'total_vacation_count'
  end
  def working_time_sheet?
    controller.action_name == 'working_time_sheet'
  end

  def get_title
    title_map[controller.action_name]
  end

end
