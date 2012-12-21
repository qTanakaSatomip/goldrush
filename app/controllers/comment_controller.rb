# -*- encoding: utf-8 -*-
class CommentController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @comment_pages, @comments = paginate :comments, :per_page => 10, :conditions => "deleted = 0 "
  end

  def show
    @comment = Comment.find(params[:id], :conditions => "deleted = 0 ")
  end

  def new
    @comment = Comment.new
    @comment.weekly_report_id = params[:parent_id]
  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.comment_date = Date.today
    set_user_column @comment
    if @comment.save
      flash[:notice] = "コメント情報を作成しました。"
      #redirect_to :action => 'list'
      redirect_to params[:back_to]
    else
      render :action => 'new'
    end
  end

  def edit
    @comment = Comment.find(params[:id], :conditions => "deleted = 0 ")
  end

  def update
    @comment = Comment.find(params[:id], :conditions => "deleted = 0 ")
    set_user_column @comment
    if @comment.update_attributes(params[:comment])
      flash[:notice] = "コメント情報を変更しました。"
      #redirect_to :action => 'show', :id => @comment
      redirect_to params[:back_to]
    else
      render :action => 'edit'
    end
  end

  def destroy
    #Comment.find(params[:id]).destroy
    comment = Comment.find(params[:id], :conditions => "deleted = 0 ")
    comment.deleted = 9
    set_user_column comment
    comment.save!
    redirect_to :action => 'list'
  end
end
