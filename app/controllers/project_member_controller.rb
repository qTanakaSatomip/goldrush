# -*- encoding: utf-8 -*-
class ProjectMemberController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @project = Project.find(params[:id], :conditions => "deleted = 0")
    @project_member_pages, @project_members = paginate :project_members, :conditions =>["deleted = 0 and project_id = ?", @project.id], :per_page => current_user.per_page
    @pic_select_items = User.pic_select_items
  end

  def show
    @project_member = ProjectMember.find(params[:id])
  end

  def new
    @project_member = ProjectMember.new
  end

  def create
    @project_member = ProjectMember.new(params[:project_member])
    set_user_column @project_member
    @project_member.save!
    flash[:notice] = 'ProjectMember was successfully created.'
    redirect_to :action => 'list'
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def edit
    @project_member = ProjectMember.find(params[:id])
  end

  def update
    @project_member = ProjectMember.find(params[:id], :conditions =>["deleted = 0"])
    @project_member.attributes = params[:project_member]
    set_user_column @project_member
    @project_member.save!
    flash[:notice] = 'ProjectMember was successfully updated.'
    redirect_to :action => 'show', :id => @project_member
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  def destroy
    @project_member = ProjectMember.find(params[:id], :conditions =>["deleted = 0"])
    @project_member.deleted = 9
    set_user_column @project_member
    @project_member.save!
    
    redirect_to(params[:back_to] || {:action => 'list'})
  end

  def add_member
    @project = Project.find(params[:id], :conditions => "deleted = 0")
    @project_member = ProjectMember.new(params[:project_member])
    @project_member.project_id = @project.id
    if ProjectMember.find(:first, :conditions => ["deleted = 0 and project_id = ? and user_id = ?", @project.id, @project_member.user_id])
      flash[:warning] = '既にプロジェクトに参加しています'
      redirect_to :action => 'list', :id => @project, :back_to => params[:back_to]
      return
    end
    set_user_column @project_member
    @project_member.save!
    flash[:notice] = 'プロジェクトにメンバーを追加しました'
    redirect_to :action => 'list', :id => @project, :back_to => params[:back_to]
  end

end
