# -*- encoding: utf-8 -*-
class Contract < ActiveRecord::Base
  include AutoTypeName

  has_many :interviews, :conditions => ["interviews.deleted = 0"]
  belongs_to :upper_contract_term, :class_name => 'ContractTerm'
  belongs_to :down_contract_term, :class_name => 'ContractTerm'
  belongs_to :contract_pic, :class_name => 'User'
  
  def contract_employee_name
   if self.contract_pic_id
     employee = Employee.find(self.contract_pic_id)
     employee ? employee.employee_name : ""
   end
  end
end
