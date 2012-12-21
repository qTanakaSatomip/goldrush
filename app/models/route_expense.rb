# -*- encoding: utf-8 -*-
class RouteExpense < ActiveRecord::Base

  has_many :route_expense_details
  belongs_to :user
  
  
end
