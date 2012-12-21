class Comment < ActiveRecord::Base
  belongs_to :weekly_report
  belongs_to :user
  
  validates_presence_of :content
  validates_length_of :content, :maximum=>4000
  
end
