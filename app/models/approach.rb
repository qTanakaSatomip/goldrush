class Approach < ActiveRecord::Base
  include AutoTypeName
  belongs_to :biz_offer
  belongs_to :bp_member
  belongs_to :approach_upper_contract_term, :class_name => 'ContractTerm'
  belongs_to :approach_down_contract_term, :class_name => 'ContractTerm'
  belongs_to :approach_pic, :class_name => 'User'
  has_many :interviews, :conditions => ["interviews.deleted = 0"]
  has_one :contract
  
  def approach_employee_name
   if self.approach_pic_id
     employee = Employee.find(self.approach_pic_id)
     employee ? employee.employee_name : ""
   end
  end
  
  def process_interview
    self.interviews.each do |interview|
puts ">>>>>>>>>>>>>>>>>>>>> #{interview.interview_status_type}"
      return true if interview.interview_status_type != 'finished'
    end
    return false
  end
  
  def last_interview
    Interview.find(:first, :conditions => ["deleted = 0 and approach_id = ?", self], :order => "interview_number desc")
  end
  
  def approach_status_type_active
    # 失敗してないステータスを並べ立てる(提案中、提案調整中、面談結果待ち、成約)
    self.approach_status_type == 'approaching' || self.approach_status_type == 'adjust' || self.approach_status_type == 'result_waiting' || self.approach_status_type == 'success'
  end
  
end
