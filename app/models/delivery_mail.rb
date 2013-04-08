# -*- encoding: utf-8 -*-
class DeliveryMail < ActiveRecord::Base
  attr_accessible :bp_pic_group_id, :content, :id, :mail_bcc, :mail_cc, :mail_from, :mail_from_name, :mail_send_status_type, :mail_status_type, :owner_id, :planned_setting_at, :send_end_at, :subject, :lock_version
  after_initialize :default_values

  def default_values
    self.mail_status_type ||= 'unsend'
    self.mail_send_status_type ||= 'ready'
  end
  
  def unsent_mails_id
	  	current = Time.now
  	  ready_mails = DeliveryMail.find(:all,
	  	  	:conditions=>["mail_status_type=? and mail_send_status_type=?", "unsend", "ready"])
  	  ready_mails.select{|m| m.planned_setting_at >= current}.map{|m| m.id}
  end
  
  def send_mails(id)
  end

end
