# -*- encoding: utf-8 -*-
class DeliveryMail < ActiveRecord::Base
  has_many :delivery_mail_targets, :conditions => "delivery_mail_targets.deleted = 0"
  attr_accessible :bp_pic_group_id, :content, :id, :mail_bcc, :mail_cc, :mail_from, :mail_from_name, :mail_send_status_type, :mail_status_type, :owner_id, :planned_setting_at, :send_end_at, :subject, :lock_version
  after_initialize :default_values

  def default_values
    self.mail_status_type ||= 'unsend'
    self.mail_send_status_type ||= 'ready'
  end
  
  def DeliveryMail.send_mails(id, destination_list)
	  	# 
	  	fetch_key = "mailer: " + Time.now.to_s + " " + rand().to_s
	  	
	  DeliveryMail.
		  where("id=? and mail_send_status_type=? and mail_status_type=? and planned_setting_at<=?",
			  	id, "ready", "unsend", Time.now.to_s(:db)).
		  update_all("mail_send_status_type='running', updated_user='#{fetch_key}'")
	  
	  # Send Mail
	  	ActiveRecord::Base.transaction do
  			mails = DeliveryMail.where("id=? and mail_send_status_type=? and updated_user=?", id, "running", fetch_key)
  			p mails.length
  			dm = mails.shift
  			destination_list.each {|d|
  				p d
  				p d.instance_of?(String)
  		# 		Mailer.send(
  		# 			destination: d,
  		# 			cc: dm.mail_cc,
  		# 			bcc: dm.mail_bcc,
  		# 			from: dm.mail_from,
  		# 			subject: dm.subject,
  		# 			body: dm.content
				# ).deliver
  				Mailer.deliver_send(
  					d,
  					dm.mail_cc,
  					dm.mail_bcc,
  					dm.mail_from,
  					dm.subject,
  					dm.content
				)
  			}
	  	end
	  
	  DeliveryMail.
		  where("id=? and mail_send_status_type=? and updated_user=?", id, "running", fetch_key).
		  update_all("mail_send_status_type='finished'")
  end
  
  
 #  class TestMailer
	# 	def initialize(cc, bcc, from, subject, body)
	# 		@cc = cc
	# 		@bcc = bcc
	# 		@from = from
	# 		@subject = subject
	# 		ac = ActionController::Base.new
	# 		@body = ac.render_to_string(
	# 			:partial => "delivery_mails/mail_body",
	# 			:locals => {:content => body}
	# 		) 
	# 	end	
		
	# 	def send(destination)
	# 		p destination
	# 		p @cc
	# 		p @bcc
	# 		p @from 
	# 		p @subject
	# 		p @body
	# 	end
	# end
	
	# Private Mailer
	class Mailer < ActionMailer::Base
		
		# def initialize(cc, bcc, from, subject, body)
		# 	@cc = cc
		# 	@bcc = bcc
		# 	@from = from
		# 	@subject = subject
		# end
		
		def send(destination, cc, bcc, from, subject, body)
			p "======================"
			
			mail(
				recipients: destination,
				cc: cc,
				bcc: bcc,
				from: from, 
				subject: subject,
				body: ActionController::Base.new.render_to_string(
					:partial => "delivery_mails/mail_body",
					:locals => {:content => body}
				)
			)
		end
			
		# def send(params)
		# 	mail(
		# 		recipients: params[:destination],
		# 		cc: params[:cc],
		# 		bcc: params[:bcc],
		# 		from: params[:from], 
		# 		subject: params[:subject],
		# 		body: ActionController::Base.new.render_to_string(
		# 			:partial => "delivery_mails/mail_body",
		# 			:locals => {:content => params[:body]}
		# 		)
		# 	)
		# end
	end
	  
end
