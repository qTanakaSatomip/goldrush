# -*- encoding: utf-8 -*-
class BaseDate < ActiveRecord::Base
  
  validates_length_of :comment1, :maximum=>255, :allow_blank => true

  def holiday?
    [0,6].include?(self.day_of_week.to_i) || self.holiday_flg == 1
  end

  def BaseDate.is_holiday?(date)
    find(:first, :conditions => ["deleted = 0 and calendar_date = ?", date]).holiday?
  end

end
