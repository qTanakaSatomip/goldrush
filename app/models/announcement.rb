class Announcement < ActiveRecord::Base
  validates_presence_of :announce_message
  validates_length_of :announce_message, :maximum=>4000
  
  def Announcement.get_my_home_announce
    announcement = find(:first, :conditions => "deleted = 0 and announce_section = 'my_home' and announce_key = '1'")
    announcement = new({:announce_section => 'my_home', :announce_key => '1'}) unless announcement
    return announcement
  end
end
