class Department < ActiveRecord::Base
  has_many :employees
  
  validates_presence_of :department_code
  validates_presence_of :department_name
  validates_length_of :department_code, :maximum=>40
  validates_length_of :department_name, :maximum=>100
  validates_length_of :department_shortname, :maximum=>100, :allow_blank => true
  validates_numericality_of :display_order, :only_integer => true
  
end
