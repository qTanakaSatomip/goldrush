class DeliveryMailTarget < ActiveRecord::Base
  attr_accessible :bp_pic_id, :delivery_mail_id, :id, :owner_id
  
  def target_id_list(search_id)
	  	DeliveryMailTarget.find(:all, :conditions=>["delivery_mail_id=?", search_id])
  end
end
