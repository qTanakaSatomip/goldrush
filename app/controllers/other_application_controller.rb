class OtherApplicationController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @calendar = true
    @approval_authorities = ApprovalAuthority.find(:all, :conditions => ["user_id = ? and approver_type = ? and active_flg = ? and deleted = 0", current_user.id, 'other_approval', 1], :order => 'approver_id')
    @other_application_pages, @other_applications = paginate(:other_applications, :per_page => 30, :conditions => ["user_id = ? and deleted = 0", current_user.id], :order => 'application_date DESC, id DESC ')
  end
  
  def list_by_approver
    @other_application_pages, @other_applications = paginate(:other_applications, :per_page => 30, :conditions => ["approver_id = ? and deleted = 0", current_user.approver.id])
  end
  
  def do_search
    @calendar = true
    parseTimes(params)
    if params[:date_from] == "" && params[:date_to] == ""
      start_date = Date.today - 2.month
      end_date = Date.today + 1.month
    elsif params[:date_from] != "" && params[:date_to] == ""
      start_date = params[:date_from].to_date
      end_date = start_date
    elsif params[:date_from] == "" && params[:date_to] != ""
      end_date = params[:date_to].to_date
      start_date = end_date
    else
      start_date = params[:date_from].to_date
      end_date = params[:date_to].to_date
    end
    
    @approval_authorities = ApprovalAuthority.find(:all, :conditions => ["user_id = ? and approver_type = ? and active_flg = ? and deleted = 0", current_user.id, 'other_approval', 1], :order => 'approver_id')
    @other_application_pages, @other_applications = paginate(:other_applications, :per_page => 30, :conditions => ["user_id = ? and deleted = 0 and application_date between ? and ?", current_user.id, start_date, end_date])
    render :action => 'list'
  end
  
  def show
    @other_application = OtherApplication.find(params[:id], :conditions => "deleted = 0 ")
    @edit_type = @other_application.working_option_type
    if params[:back_to]
      session[:back_to] = params[:back_to]
    end
  end
  
  def show_by_user
    @application_approval = ApplicationApproval.find(params[:app_approval_id], :conditions => "deleted = 0 ")
    @other_application = OtherApplication.find(params[:id], :conditions => "deleted = 0 ")
    @edit_type = @other_application.working_option_type
    if params[:back_to]
      session[:back_to] = params[:back_to]
    end
    render :action => 'show'
  end

  def popup_new
    new
    params[:mode] = 'popup_new'
    render :action => 'new', :layout => 'popup'
  end

  # 他勤怠新規申請画面表示
  #  チェック
  #  1. 同日に同じ区分の他勤怠申請がされている(warning)
  def new
    flash[:notice] = ""
    #他勤怠申請の区分を追加・削除したらここも変更する
    @typs = [['直行申請','go_directly_app'],['直帰申請','back_directly_app'],['遅刻申請','come_lately_app'],['早退申請','leave_early_app']]
    @calendar = true
    @other_application = OtherApplication.new
    @other_application.working_option_type = params[:working_option_type] || 'go_directly_app'
    @other_application.application_date = Time.now
    if params[:daily_working_id]
      daily_working = DailyWorking.find(params[:daily_working_id])
      if daily_working.get_other_application(@other_application.working_option_type)
        flash[:warning] = "すでに#{@other_application.working_option_type_name}申請されています"
      end
      @other_application.target_date = daily_working.working_date
      if @other_application.working_option_type == 'over_time_app' or @other_application.working_option_type == 'leave_early_app'
        @other_application.end_time = params[:out_time].to_i if params[:out_time]
      elsif @other_application.working_option_type == 'come_lately_app'
        @other_application.start_time = params[:in_time].to_i if params[:in_time]
      end
    else
      @other_application.target_date = Date.today.to_date
    end
  end

  # 他勤怠新規登録処理
  # チェック
  #  1. 作業日が存在しない
  #  2. 同日に同じ区分の他勤怠申請がされている(warning)
  #  3. 休日に他勤怠は登録できない
  #  4. 承認者が一人もいない場合(承認者マスタ登録されていない)
  def create
    @typs = [['直行申請','go_directly_app'],['直帰申請','back_directly_app'],['遅刻申請','come_lately_app'],['早退申請','leave_early_app']]
    parseTimes(params)
    @other_application = OtherApplication.new
    @other_application.set_time_str(params[:other_application])
    @other_application.attributes = params[:other_application]
    @other_application.user_id = current_user.id
#    @other_application.approval_status_type = 'entry' # TODO: 廃止予定
    
    if @other_application.target_date.blank?
      raise ValidationAbort.new("対象日を入力してください")
    end
    
    daily_working = @other_application.get_daily_working
    unless daily_working
      raise ValidationAbort.new("対象日が初期化されていません。勤務表の初期化を行ってください")
    end

    if daily_working.get_other_application(@other_application.working_option_type)
      raise ValidationAbort.new("すでに#{@other_application.working_option_type_name}申請されています")
    end

    if @other_application.monthly_working_applicated?
      raise ValidationAbort.new('対象月は、すでに勤務表が提出されています')
    end

    if daily_working.holiday_flg == 1
      raise ValidationAbort.new('休日には、設定できません')
    end

    # 全日出勤、午前休、午後休、休日出勤以外の勤怠はオプションをつけることができない
    HolidayApplication.get_holiday_applications(@other_application.user_id, @other_application.target_date, @other_application.target_date).each do |x|
      if !DailyWorking.regular_working_type.include?(x.working_type)
        raise ValidationAbort.new("すでに#{x.working_type_name}申請されています")
      end
    end
    if !daily_working.action_type_blank? && !DailyWorking.regular_working_type.include?(daily_working.working_type)
      raise ValidationAbort.new("#{daily_working.working_type_name}の日には、申請できません")
    end

    #休暇申請での全て承認者を取る。
    approval_authorities = ApprovalAuthority.find(:all, :conditions => ["user_id = ? and approver_type = ? and active_flg = 1 and deleted = 0", current_user.id, 'working_xxx'])
    if approval_authorities.empty?
      raise ValidationAbort.new('承認者が一人も登録されていません。承認権限設定をしてください')
    end
    
    ActiveRecord::Base.transaction do
      # もし、作業日が確定していた場合、未確定に戻す
      if daily_working.action_type == 'fixed'
        daily_working.action_type = 'updated'
        set_user_column daily_working
        daily_working.save!
      end
      #if @other_application.working_option_type == 'come_lately_app'
        #daily_working.delayed_cancel_flg = @other_application.delayed_cancel_flg
        #daily_working.delayed_cancel_user_id = current_user.id 
      #end
      #set_user_column daily_working
      #daily_working.save!

      base_application = BaseApplication.new
      base_application.user_id = current_user.id
      base_application.application_type = 'other_app'
      base_application.approval_status_type = 'entry'
      base_application.application_date = @other_application.application_date
      set_user_column base_application
      base_application.save!

      @other_application.base_application_id = base_application.id
      set_user_column @other_application
      @other_application.save!
      #申請に承認者を設定
      count = 0
      for approval_authority in approval_authorities
        count = count + 1
        application_approval = ApplicationApproval.new
        application_approval.user_id = approval_authority.user_id
        application_approval.base_application_id = base_application.id
#        application_approval.other_application_id = @other_application.id
        application_approval.application_type = 'other_app'
        application_approval.application_date = @other_application.application_date
        application_approval.approver_id = approval_authority.approver_id
        application_approval.approval_status_type = 'entry'
        application_approval.approval_order = count
        set_user_column application_approval
        application_approval.save!
      end
    end
    app_type = "他勤怠"
    if @other_application.working_option_type == 'over_time_app'
      app_type = "残業"
    end
    flash[:notice] = "#{app_type}申請情報を作成しました。"
    
    if params[:mode] == 'popup_new'
      render :text => '<script type="text/javascript">popup_close();</script>', :layout => 'popup' # window.opener.reload();
    else
      redirect_to :action => 'show', :id => @other_application
    end
  rescue ValidationAbort
    flash[:warning] = $!
    @calendar = true
    if params[:mode] == 'popup_new'
      render :action => 'popup_err', :layout => 'popup'
    else
      params[:working_option_type] = @other_application.working_option_type
      render :action => 'new'
    end
  rescue ActiveRecord::RecordInvalid
    @calendar = true
    if params[:mode]
      render :action => 'new', :layout => 'popup'
    else
      render :action => 'new'
    end
  end

  def edit
    flash[:notice] = ""
    @calendar = true
    @other_application = OtherApplication.find(params[:id], :conditions => "deleted = 0 ")
    #他勤怠申請の区分を追加・削除したらここも変更する
    @typs = [['直行申請','go_directly_app'],['直帰申請','back_directly_app'],['遅刻申請','come_lately_app'],['早退申請','leave_early_app']]
  end

  def update
    @typs = [['直行申請','go_directly_app'],['直帰申請','back_directly_app'],['遅刻申請','come_lately_app'],['早退申請','leave_early_app']]
    parseTimes(params)
    @other_application = OtherApplication.find(params[:id], :conditions => "deleted = 0 ")
    @other_application.set_time_str(params[:other_application])
    @other_application.attributes = params[:other_application]
    @other_application.user_id = current_user.id
    base_application = @other_application.base_application
    if base_application.approval_status_type == 'fixed'
      raise ValidationAbort.new('すでに確定されているため、変更できません')
    end

    daily_working = @other_application.get_daily_working

    if daily_working.holiday_flg == 1
      raise ValidationAbort.new('休日には、設定できません')
    end

    ActiveRecord::Base.transaction do
      if base_application.approval_status_type == 'reject'
        for application_approval in base_application.application_approvals
          application_approval.application_date = @other_application.application_date
          application_approval.approval_status_type = 'retry'
          set_user_column application_approval
          application_approval.save!
        end
        base_application.approval_status_type = 'retry'
      end
      if @other_application.working_option_type == 'come_lately_app'
        daily_working.delayed_cancel_flg = @other_application.delayed_cancel_flg
        if daily_working.delayed_cancel_flg == 1
          daily_working.delayed_cancel_user_id = current_user.id 
        else
          daily_working.delayed_cancel_user_id = nil
        end
        set_user_column daily_working
        daily_working.save!
      end
      
      base_application.application_date = @other_application.application_date
      set_user_column base_application
      base_application.save!

      set_user_column @other_application
      @other_application.save!
    end
    app_type = "他勤怠"
    if @other_application.working_option_type == 'over_time_app'
      app_type = "残業"
    end
    flash[:notice] = "#{app_type}申請情報を更新しました。"
    redirect_to(params[:back_to] || {:action => 'list'})
  rescue ValidationAbort
    flash[:warning] = $!
    @calendar = true
    render :action => 'edit'
  rescue ActiveRecord::RecordInvalid
    @calendar = true
    render :action => 'edit'
  end

  def destroy
    other_application = OtherApplication.find(params[:id], :conditions => "deleted = 0 ")
    other_application.deleted = 9
    set_user_column other_application
    other_application.save!
    redirect_to :action => 'list'
  end

  
end
