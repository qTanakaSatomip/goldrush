class ApprovalAuthority < ActiveRecord::Base
  include AutoTypeName
  belongs_to :user
  belongs_to :applover, :class_name => 'User'

end
