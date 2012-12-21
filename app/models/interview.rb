class Interview < ActiveRecord::Base
  include AutoTypeName

  belongs_to :interview_bp, :class_name => 'BusinessPartner'
  belongs_to :interview_bp_pic, :class_name => 'BpPic'
  belongs_to :approach
  belongs_to :interview_pic, :class_name => 'User'
  
  def interview_employee_name
   if self.interview_pic_id
     employee = Employee.find(self.interview_pic_id)
     employee ? employee.employee_name : ""
   end
  end
  
end
