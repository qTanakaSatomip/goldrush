# -*- encoding: utf-8 -*-
class AttachmentFileController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  def create
    
    upfile = params[:upfile]
    
    if upfile.blank?
      flash[:notice] = 'ファイルを選択してください'
      redirect_to params[:back_to]
      return
    end
    
    Contract.transaction do
      attachment_file = AttachmentFile.new
      
      # attachmentFileに項目を入れるメソッド
      # 親テーブル名
      table_name = params[:parent_table]
      attachment_file.parent_table_name = table_name
      # 親テーブルId
      parent_id = params[:parent_id]
      attachment_file.parent_id = parent_id
      # 添付ファイル名（オリジナルのファイル名）
      attachment_file.file_name = upfile.original_filename
      # 拡張子
      ext = attachment_file.check_and_get_ext(upfile.original_filename)
      attachment_file.extention = ext
      
      set_user_column attachment_file
      attachment_file.save!
      
      # 保存するファイル名
      store_file_name = attachment_file.create_store_parent_table_name
      attachment_file.store(upfile, store_file_name)
    end
    
    flash[:notice] = 'AttachmentFile was successfully uploaded.'
    redirect_to params[:back_to]
  rescue ActiveRecord::RecordInvalid
    render :controller => params[:parent_table], :action => 'show', :id => params[:parent_id]
  end




  def destroy
    attachment_file = AttachmentFile.find(params[:id], :conditions =>["deleted = 0"])
    bp_member_id = attachment_file.parent_id
    attachment_file.deleted = 9
    attachment_file.deleted_at = Time.now
    set_user_column attachment_file
    attachment_file.save!
    
    redirect_to :controller => 'bp_member', :action => 'show', :id => bp_member_id
  end


  def download
    attachment_file = AttachmentFile.find(params[:id], :conditions =>["deleted = 0"])
    send_file(attachment_file.file_path)
  end

end
