class ExpenseDetail < ActiveRecord::Base
  include AutoTypeName
  belongs_to :payment
  belongs_to :payment_per_month
  belongs_to :payment_per_case
  belongs_to :expense_application
  belongs_to :business_trip_application
  
  
end
