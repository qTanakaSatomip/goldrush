# -*- encoding: utf-8 -*-
class EmployeeHistory < ActiveRecord::Base
  belongs_to :user
end
