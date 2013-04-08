# -*- encoding: utf-8 -*-
class DeliveryMail < ActiveRecord::Base
  attr_accessible :bp_pic_group_id, :content, :id, :mail_bcc, :mail_cc, :mail_from, :mail_from_name, :mail_send_status_type, :mail_status_type, :owner_id, :planned_setting_at, :send_end_at, :subject, :lock_version
  after_initialize :default_values

  def default_values
    self.mail_status_type ||= 'unsend'
    self.mail_send_status_type ||= 'ready'
  end
  
  def DeliveryMail.send_mails(id, destination_list)
	  	fetch_key = "mailer: " + Time.now.to_s + " " + rand().to_s
	  	 
	  DeliveryMail.
		  where("id=? and mail_send_status_type=? and mail_status_type=? and planned_setting_at<=?",
			  	id, "ready", "unsend", Time.now.to_s(:db)).
		  update_all("mail_send_status_type='running', updated_user='#{fetch_key}'")

	  	ActiveRecord::Base.transaction do
  			mails = DeliveryMail.where("id=? and mail_send_status_type=? and updated_user=?", id, "running", fetch_key)
  			mails.each {|m|
		  		mail = TestMailer.new(m.mail_cc, m.mail_bcc, m.mail_from, m.subject, m.content)
		  		destination_list.each {|d| mail.send(d)}
		  	}
	  	end
	  
	  DeliveryMail.
		  where("id=? and mail_send_status_type=? and updated_user=?", id, "running", fetch_key).
		  update_all("mail_send_status_type='finished'")
  end
end

class TestMailer
	def initialize(cc, bcc, from, subject, body)
		@cc = cc
		@bcc = bcc
		@from = from
		@subject = subject
		@body = body
	end	
	
	def send(destination)
		p destination
		p @cc
		p @bcc
		p @from 
		p @subject
		p @body
	end
end

# class Mailer < ActionMailer::Base
# 	def initialize(cc, bcc, from, subject, body)
# 		@cc = cc
# 		@bcc = bcc
# 		@from = from
# 		@subject = subject
# 		@body = body
# 	end
	
# 	def send(destination)
# 		mail(
# 			recipients: destination,
# 			cc: @cc,
# 			bcc: @bcc,
# 			from: @from, 
# 			subject: @subject,
# 			body: @body
# 		)
# 	end
# end

