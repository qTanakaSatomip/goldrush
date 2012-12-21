class WeeklyReportDetail < ActiveRecord::Base
  belongs_to :weekly_report
  
  
  validates_presence_of     :client, :content
  
end
