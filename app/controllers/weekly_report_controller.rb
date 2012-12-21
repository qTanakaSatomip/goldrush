# -*- encoding: utf-8 -*-
class WeeklyReportController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

#  def list
#    @weekly_report_pages, @weekly_reports = paginate :weekly_reports, :per_page => 10, :conditions => "deleted = 0 "
#  end

#  def list_by_user
  def list
    if user_id = params[:user_id]
      @target_user = User.find(params[:user_id], :conditions => "deleted = 0")
    else
      @target_user = current_user
    end
    if base_month_id = params[:id]
      @base_month = BaseMonth.find(base_month_id, :conditions => "deleted = 0")
    else
      @base_month = BaseMonth.get_base_month_by_date # today
    end
    @weekly_reports = WeeklyReport.find(:all, :conditions =>["deleted = 0 and user_id = ? and base_month_id = ?", @target_user.id, @base_month.id], :order => "start_date")
  end
  
  def show_by_user
    @application_approval = ApplicationApproval.find(params[:app_approval_id], :conditions => "deleted = 0 ")
    @user_id = params[:user_id]
    start_date = params[:start_date]
    end_date = params[:end_date]
    @base_month_pages, @base_months = paginate(:base_months, :per_page => 1, :include => [ :weekly_reports ], :conditions => ["base_months.deleted = 0 and weekly_reports.deleted = 0 and weekly_reports.user_id = ? and weekly_reports.start_date = ? and weekly_reports.end_date = ?", @user_id, start_date, end_date], :order => 'base_months.start_date, weekly_reports.start_date')
    render :action => 'list_by_user'
  end
  
  def show
    @weekly_report = WeeklyReport.find(params[:id], :conditions => "deleted = 0 ")
  end

  def new
    @weekly_report = WeeklyReport.new
  end

  def create
    @weekly_report = WeeklyReport.new(params[:weekly_report])
    @weekly_report.user_id = current_user.id
    set_user_column @weekly_report
    if @weekly_report.save
      #flash[:notice] = 'WeeklyReport was successfully created.'
      flash[:notice] = "週間報告を作成しました。"
      if params[:back_to]
        redirect_to params[:back_to]
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @weekly_report = WeeklyReport.find(params[:id], :conditions => "deleted = 0 ")
    @last_report = WeeklyReport.find(:first, :conditions => ["deleted = 0 and end_date = ? ", @weekly_report.start_date.to_date - 1])
  end

  def update
    @weekly_report = WeeklyReport.find(params[:id], :conditions => "deleted = 0 ")
    set_user_column @weekly_report
    if @weekly_report.update_attributes(params[:weekly_report])
      #flash[:notice] = 'WeeklyReport was successfully updated.'
      flash[:notice] = "週間報告を作成しました。"
      redirect_to params[:back_to]
    else
      render :action => 'edit'
    end
  end

  def destroy
    #WeeklyReport.find(params[:id]).destroy
    weekly_report = WeeklyReport.find(params[:id], :conditions => "deleted = 0 ")
    weekly_report.deleted = 9
    set_user_column weekly_report
    weekly_report.save!
    redirect_to :action => 'list'
  end
  
  def send_weekly_report
    ActiveRecord::Base::transaction() do
      weekly_report = WeeklyReport.find(params[:id], :conditions => "deleted = 0 ")
      #週報・出退勤表での全て承認者を取る。
      approval_authorities = ApprovalAuthority.find(:all, :conditions => ["user_id = ? and approver_type = ? and active_flg = 1 and deleted = 0", weekly_report.user_id, 'report_xxx'])
      if approval_authorities.empty?
        raise ValidationAbort.new('承認者が一人も登録されていません。承認権限設定をしてください')
      end

      now = Time.now
      # 申請基本作成
      base_application = BaseApplication.new
      base_application.user_id = weekly_report.user_id
      base_application.application_type = 'weekly_report_app'
      base_application.approval_status_type = 'entry'
      base_application.application_date = now
      base_application.save!

      weekly_report.base_application_id = base_application.id
      set_user_column weekly_report
      weekly_report.save!

      #週報に認者を設定
      order = 0
      for approval_authority in approval_authorities
        order = order + 1
        application_approval = ApplicationApproval.new
        application_approval.user_id = approval_authority.user_id
        application_approval.base_application_id = base_application.id
        application_approval.application_type = 'weekly_report_app'
        application_approval.application_date = now
        application_approval.approver_id = approval_authority.approver_id
        application_approval.approval_status_type = 'entry'
        application_approval.approval_order = order
        set_user_column application_approval
        application_approval.save!
      end
      flash[:notice] = '承認者に送りました。'
      redirect_to params[:back_to]
      return true
    end
  rescue ValidationAbort
    flash[:warning] = $!
    redirect_to params[:back_to]
  end
  
end
