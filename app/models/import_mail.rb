# -*- encoding: utf-8 -*-
class ImportMail < ActiveRecord::Base

  belongs_to :business_partner
  belongs_to :bp_pic

  def ImportMail.import
    Pop3Client.pop_mail do |m, src|
      puts">>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL IMPORT START"
      ActiveRecord::Base::transaction do

        import_mail = ImportMail.new
        
        import_mail.in_reply_to = m.in_reply_to[0] if m.in_reply_to
        import_mail.received_at = m.date
        import_mail.mail_subject = NKF.nkf('-w -J', m.subject)
        import_mail.mail_from = m.from[0]
        import_mail.set_bp
        import_mail.mail_sender_name = NKF.nkf('-w -J', m.from_addrs[0].to_s)
        import_mail.mail_to = m.to.join(",") if m.to
        import_mail.mail_cc = m.cc.join(",") if m.cc
        import_mail.mail_bcc = m.bcc.join(",") if m.bcc
        import_mail.message_source = src
        import_mail.message_id = m.message_id

        # attempt_fileのため(import_mail_idが必要)に一旦登録
        import_mail.save!
        
        
        
        #---------- mail_body ここから ----------
        if m.multipart?
          puts">>>>>>>>>>>>>>>>>>>>>>>>>>> MULTIPART MODE"
          # パートに分かれている(=返信元メールや添付ファイルが存在している)場合
          m.parts.each do |part|
            puts">>>>>>>>>>>>>>>>>>>>>>>>>>> content_type : #{part.content_type}"
            if part.content_type == 'multipart/alternative'
              puts">>>>>>>>>>>>>>>>>>>>>>>>>>> ALTERNATIVE MODE"
              # multipart/alternativeの場合、メール本文の含まれるパートなので、さらにその中のパートを調べる。
              part.parts.each do |ppart|
                puts">>>>>>>>>>>>>>>>>>>>>>>>>>> content_type in alternative : #{ppart.content_type}"
                if ppart.content_type == 'text/plain'
                  puts">>>>>>>>>>>>>>>>>>>>>>>>> REGIST MAIL BODY(text/plain in alternative)"
                  # text/plainの場合、メール本文（返信だと添付ファイルの可能性も・・・）。
                  import_mail.mail_body = get_encode_body(m, ppart.body)
                  break
                end # ppart.content_type == 'text/plain'
              end # part.parts.each do
              if import_mail.mail_body.blank?
                puts">>>>>>>>>>>>>>>>>>>>>>>>> REGIST MAIL BODY(other in alternative)"
                # メール本文にまだ何も代入されてない(=プレーンテキストがなかった)場合、
                # 最初のbodyの値をエンコードして代入する
                import_mail.mail_body = get_encode_body(m, part.parts[0].body)
              end # import_mail.mail_body.blank?
            elsif !part.disposition_param('filename').blank?
              # filenameがある = 添付ファイルなのでパス
              puts">>>>>>>>>>>>>>>>>>>>>>>>> REGIST ATTEMPT FILE"
              
              
              #---------- 添付ファイル ここから ----------
              upfile = part.body
              part.base64_decode
              file_name = part.disposition_param('filename')
              
#              if(file_name =~ /=\?ISO-2022-JP\?B\?/)
                file_name = NKF.nkf('-w -J', file_name)
                puts">>>>>>>>>>>>>>>>>>>>>>>>>>> decoded_file_name : #{file_name}"
#              end
              
              attachment_file = AttachmentFile.new
              attachment_file.create_by_import(upfile, import_mail.id, file_name)
              
 #             ActiveRecord::Base.transaction do
 #               attachment_file = AttachmentFile.new
 #               # attachmentFileに項目を入れるメソッド
 #               # 親テーブル名
 #               attachment_file.parent_table_name = "import_mails"
 #               # 親テーブルId
 #               attachment_file.parent_id = 200
 #               # 添付ファイル名（オリジナルのファイル名）
 #               attachment_file.file_name = file_name
 #               # 拡張子
 #               ext = attachment_file.check_and_get_ext(file_name)
 #               attachment_file.extention = ext
 #               
 #               attachment_file.created_user = 'import_mail'
 #               attachment_file.updated_user = 'import_mail'
 #               attachment_file.save!
 #               
 #               # 保存するファイル名
 #               store_file_name = attachment_file.create_store_parent_table_name
 #               attachment_file.store(upfile, store_file_name)
 #             end # transaction
              
              #---------- 添付ファイル ここまで ----------
              
              puts">>>>>>>>>>>>>>>>>>>>>>>>> REGIST ATTEMPT FILE"
              
            elsif part.content_type == 'text/plain'
              # 添付ファイルでなくtext/plainの場合、メール本文。
              # 上書きされる可能性あり？
              puts">>>>>>>>>>>>>>>>>>>>>>>>> REGIST MAIL BODY(text/plain)"
              import_mail.mail_body = get_encode_body(m, part.body)
            else
              # multipart/alternativeでもファイルでもtext/plainでもない場合は何もしない（ありえない？）
            end
          end # m.parts.each do
        else
          puts">>>>>>>>>>>>>>>>>>>>>>>>>>> SINGLEPART MODE"
          puts">>>>>>>>>>>>>>>>>>>>>>>>>>> REGIST MAIL BODY"
          # パートに分かれていなければ、bodyをそのままエンコードして代入する
          import_mail.mail_body = get_encode_body(m, m.body)
        end # m.multipart?
        #---------- mail_body ここまで ----------
        
        
        import_mail.created_user = 'import_mail'
        import_mail.updated_user = 'import_mail'
        import_mail.save!
        
        
      end # transaction
      puts">>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL IMPORT END"
    end # Pop3Client.pop_mail do
  end # def

  def wanted?
    self.unwanted != 1
  end

  def set_bp
    mail_from = self.mail_from
    mail_bp_pic = BpPic.find(:first, :conditions => ["deleted = 0 and email1 = ? or email2 = ?", mail_from, mail_from])
    if mail_bp_pic.blank?
      mail_business_partner = BusinessPartner.find(:first, :conditions => ["deleted = 0 and email = ?", mail_from])
      if !mail_business_partner.blank?
        self.business_partner_id = mail_business_partner.id
      end
    else
      self.bp_pic_id = mail_bp_pic.id
      self.business_partner_id = mail_bp_pic.business_partner.id
    end
  end

  def get_bizp(id)
    return BusinessPartner.find(id)
  end

  def get_bpic(id)
    return BpPic.find(id)
  end

  def attachment?
    AttachmentFile.count(:conditions => ["deleted = 0 and parent_table_name = 'import_mails' and parent_id = ?", self]) > 0
#    !AttachmentFile.find(:first, :conditions => ["deleted = 0 and parent_table_name = 'import_mails' and parent_id = ?", self]).blank?
  end
  
  def change_type(type_name)
    if type_name == "biz_offer"
      self.biz_offer_flg = 1
      self.save!
    end
  end

private
  def ImportMail.get_encode_body(mail, body)
    if mail.transfer_encoding == 'ISO-2022-JP'
      return NKF.nkf('-w -J', body)
    elsif mail.transfer_encoding == 'UTF-8'
      return body
    else
      # そのほかは
      return NKF.nkf('-w', body)
    end
  end

CTYPE_TO_EXT = {
  'image/jpeg' => 'jpeg',
  'image/gif'  => 'gif',
  'image/png'  => 'png',
  'image/tiff' => 'tiff',
  'application/vnd.ms-excel' => 'xls',
  'application/msword' => 'doc'
}

def ext( mail )
  CTYPE_TO_EXT[mail.content_type] || 'txt'
end



end
