# -*- encoding: utf-8 -*-
class DeliveryMail < ActiveRecord::Base
  attr_accessible :bp_pic_group_id, :content, :id, :mail_bcc, :mail_cc, :mail_from, :mail_from_name, :mail_send_status_type, :mail_status_type, :owner_id, :planned_setting_at, :send_end_at, :subject, :lock_version
  after_initialize :default_values

  def default_values
    self.mail_status_type ||= 'unsend'
    self.mail_send_status_type ||= 'ready'
  end
  
  def send_mails(id)
	  	mails_id = unsent_mails(id)
	  	
	  	DeliveryMail.transaction do
	  		mails_id.each {|m|
	  			m.mail_send_status_type = "ready"
		  		m.save!
	  		}
	  	end
	  	
	  	DeliveryMail.transaction do
	  		mails_id.each {|m|
	  			m.mail_send_status_type = "finish"
	  			m.mail_status_type = "sent"
	  			m.save!
	  		}
	  	end
  end
  
  # require 'action_mailer'

	class DeliveryMailer < ActionMailer::Base
		def send()
			mail(
				recipients:
				cc:
				bcc:
				from:
				subject:
				body:
			)
		end
	end
	
  def unsent_mails(id)
	  	current = Time.now
  	  ready_mails = DeliveryMail.find(:all,
	  	  	:conditions=>["id=? and mail_status_type=? and mail_send_status_type=?", id, "unsend", "ready"])
  	  ready_mails.select{|m| m.planned_setting_at <= current}.map{|m| m.id}
  end

end
