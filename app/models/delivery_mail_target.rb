class DeliveryMailTarget < ActiveRecord::Base
  attr_accessible :bp_pic_id, :delivery_mail_id, :id, :owner_id
  
  def targets_id(search_id)
	  	DeliveryMailTarget.find(:all, :conditions=>["delivery_mail_id=?", search_id])
  end
end
