# -*- encoding: utf-8 -*-
class BaseMonth < ActiveRecord::Base
  has_many :monthly_workings
  has_many :weekly_reports
  
  def next_month
    BaseMonth.find(:first, :conditions => ["deleted = 0 and start_date = ?", (self.end_date + 1)])
  end

  def last_month
    BaseMonth.find(:first, :conditions => ["deleted = 0 and end_date = ?", (self.start_date - 1)])
  end

  def BaseMonth.get_base_month_by_date(target_date = nil)
    target_date = Date.today unless target_date
    BaseMonth.find(:first, :conditions => ["deleted = 0 and start_date <= ? and end_date >= ?", target_date, target_date])
  end

  def BaseMonth.get_next_month_by_date(target_date = nil)
    target_date = Date.today.next_month unless target_date
    BaseMonth.find(:first, :conditions => ["deleted = 0 and start_date <= ? and end_date >= ?", target_date, target_date])
  end

end
