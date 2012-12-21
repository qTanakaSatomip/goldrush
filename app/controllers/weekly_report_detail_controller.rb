class WeeklyReportDetailController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @weekly_report_detail_pages, @weekly_report_details = paginate :weekly_report_details, :per_page => 10, :conditions => "deleted = 0 "
  end

  def show
    @weekly_report_detail = WeeklyReportDetail.find(params[:id], :conditions => "deleted = 0 ")
  end

  def new
    @weekly_report_detail = WeeklyReportDetail.new
    @weekly_report_detail.weekly_report_id = params[:parent_id]
  end

  def create
    @weekly_report_detail = WeeklyReportDetail.new(params[:weekly_report_detail])
    set_user_column @weekly_report_detail
    if @weekly_report_detail.save
      flash[:notice] = "週間報告を作成しました。"
      #redirect_to :action => 'list'
      #redirect_to :controller => 'weekly_report', :action => 'list_by_user'
      redirect_to params[:back_to]
    else
      render :action => 'new'
    end
  end

  def edit
    @weekly_report_detail = WeeklyReportDetail.find(params[:id], :conditions => "deleted = 0 ")
  end

  def update
    @weekly_report_detail = WeeklyReportDetail.find(params[:id], :conditions => "deleted = 0 ")
    set_user_column @weekly_report_detail
    if @weekly_report_detail.update_attributes(params[:weekly_report_detail])
      flash[:notice] = "週間報告を変更しました。"
      #redirect_to :action => 'show', :id => @weekly_report_detail
      #redirect_to :controller => 'weekly_report', :action => 'list_by_user'
      redirect_to params[:back_to]
    else
      render :action => 'edit'
    end
  end

  def destroy
    #WeeklyReportDetail.find(params[:id]).destroy
    weekly_report_detail = WeeklyReportDetail.find(params[:id], :conditions => "deleted = 0 ")
    weekly_report_detail.deleted = 9
    set_user_column weekly_report_detail
    weekly_report_detail.save!
    redirect_to :action => 'list'
  end
end
