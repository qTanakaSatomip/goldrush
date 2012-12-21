class ApplicationApprovalController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def do_search
    # TODO: 検索機能
  end

  def user_list
    @target_user = current_user

    @approver_type = params[:approver_type] || 'report_xxx'
    @approval_authorities = ApprovalAuthority.find(:all, :conditions => ["deleted = 0 and approver_id = ? and approver_type = ?", @target_user.id, @approver_type], :order => "user_id")
  end

  def show
    @application_approval = ApplicationApproval.find(params[:id], :conditions => "deleted = 0 ")
  end

  def new
    @application_approval = ApplicationApproval.new
  end

  def create
    @application_approval = ApplicationApproval.new(params[:application_approval])
    if @application_approval.save
      flash[:notice] = 'ApplicationApproval was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @application_approval = ApplicationApproval.find(params[:id], :conditions => "deleted = 0 ")
  end

  def update
    @application_approval = ApplicationApproval.find(params[:id], :conditions => "deleted = 0 ")
    if @application_approval.update_attributes(params[:application_approval])
      flash[:notice] = 'ApplicationApproval was successfully updated.'
      redirect_to :action => 'show', :id => @application_approval
    else
      render :action => 'edit'
    end
  end

  def destroy
    #ApplicationApproval.find(params[:id]).destroy
    application_approval = ApplicationApproval.find(params[:id], :conditions => "deleted = 0 ")
    application_approval.deleted = 9
    application_approval.save!
    redirect_to(params[:back_to] || {:action => 'list'})
  end
  
  #申請ステータスを変更
  def change_approval_status
    app = params[:application_type]                       # monthly_working_app
    status = params[:approval_status_type]                # reject
    send("do_change_#{app}", params[:id], status)         # 44041
    flash[:notice] = approval_status_message(app, status)
    redirect_to params[:back_to]
  end

  def reject
    @application_approval = ApplicationApproval.find(params[:id], :conditions => "deleted = 0")
    @comment = Comment.new(params[:comment])
    @comment.application_approval_id = @application_approval.id
    if request.post?
      ActiveRecord::Base::transaction() do
        @comment.save!
        change_approval_status
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'reject'
  end

# ここから内部処理
private
  # 申請承認の更新処理
  def update_approval_status_type(application_approval_id, approval_status_type)
    application_approval = ApplicationApproval.find(application_approval_id, :conditions => "deleted = 0 ")
    old_approval_status_type = application_approval.approval_status_type
    application_approval.approval_status_type = approval_status_type
    # 却下からの変更の場合
    if old_approval_status_type == 'reject' && approval_status_type != 'reject'
      if comment = application_approval.comment
        comment.deleted = 9
        set_user_column comment
        comment.save!
      end
    end
    if approval_status_type == 'approved'
    # 承認（申請 → 承認、再申請 → 承認）の場合、承認日入れる
      application_approval.approval_date = Date.today.to_date
    else
    # 解除（承認 → 申請、却下 → 申請）の場合、承認日消す（却下の時も無駄にこの処理を行う）
      application_approval.approval_date = nil
    end
    set_user_column application_approval
    application_approval.save!
    return application_approval
  end

  #休暇申請を承認
  # 申請承認を取得。承認ステータス区分を更新
  # 確定か確定解除か?
  # →確定の場合
  #   自分の申請承認を承認(approve)にする
  #   他の承認者も確定しているか? YES -> 申請基本を確定(fixed)にする
  #   休暇申請が対象としている作業日データを取得
  #   作業日にぶら下がる他の申請(他勤怠、出張)がfixされているか? YES -> 作業日を確定(fixed)する
  # →解除の場合
  #   自分の申請承認を承認(approve)以外(指定されたもの)にする
  #   申請基本を申請中(entry)にする
  #   休暇申請が対象としている作業日データを取得
  #   作業日を編集中(updated)にする
  def do_change_holiday_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction() do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login) do |base_application|
        daily_workings = base_application.holiday_application.get_daily_workings
        daily_workings.each do |daily_working|
          # 勤怠種別が休暇申請のそれと同じのとき(未入力や別の勤怠種別(休暇申請しているのに全日で登録などを避ける)
          next unless daily_working.working_type == base_application.holiday_application.working_type
          if base_application.approval_status_type == 'fixed'
            daily_working.taxi_flg = base_application.holiday_application.taxi_flg
            daily_working.change_fixed!(current_user.login)
          elsif base_application.approval_status_type == 'entry'
            daily_working.taxi_flg = base_application.holiday_application.taxi_flg
            daily_working.revert_fixed!(current_user.login)
          end
        end
      end
    end
  end
  
  #他勤怠申請を承認
  def do_change_other_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction() do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login) do |base_application|
        daily_working = base_application.other_application.get_daily_working
        if base_application.approval_status_type == 'fixed'
          daily_working.taxi_flg = base_application.other_application.taxi_flg
          daily_working.change_fixed!(current_user.login) if daily_working.action_type != 'blank'
        elsif base_application.approval_status_type == 'entry'
          daily_working.taxi_flg = base_application.other_application.taxi_flg
          daily_working.revert_fixed!(current_user.login)
        end
      end
    end
  end
  
  #出張申請を承認
  def do_change_business_trip_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction() do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login) do |base_application|
        daily_workings = base_application.business_trip_application.get_all_working_days
        daily_workings.each do |daily_working|
          if base_application.approval_status_type == 'fixed'
            daily_working.business_trip_flg = 1
            daily_working.change_fixed!(current_user.login) if daily_working.action_type != 'blank'
          elsif base_application.approval_status_type == 'entry'
            daily_working.business_trip_flg = 0
            daily_working.revert_fixed!(current_user.login)
          end
        end
      end
    end
  end
  
  #勤務表を承認
  def do_change_monthly_working_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction do
      # 初めに各個のステータス更新
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      # 続いて基本申請のステータス更新
      application_approval.base_application.change_approval_status(current_user.login) do |base_application|
      # ↑って、"base_application = application_approval.base_application.change_approval_status(current_user.login)" じゃダメなの？
        # fixedだったら代休の計算（と月別実績保持）
        # entryだったら保持した月別実績取り消し
        # 特にfixed → entry（unfixed_flg == 1）だったら代休計算取り消し
        # それ以外（approved,reject）は何もしない
        if base_application.approval_status_type == 'fixed'
puts">>>>>> monthly_working_application : fixed"
          Vacation.calculate_compensatories(base_application)
        elsif base_application.approval_status_type == 'entry'
puts">>>>>> monthly_working_application : entry"
          base_application.monthly_working.resist_delete
          # fixed → entry
          if base_application.unfixed_flg == 1
puts">>>>>> monthly_working_application : fixed → entry"
            base_application.monthly_working_comp_reset
            base_application.unfixed_flg = 0
            base_application.save!
            
puts">>>>>> vacation.pre_resist_back"
            vacation = Vacation.find(:first, :conditions =>["deleted = 0 and user_id = ?", base_application.user_id])
            vacation.pre_resist_back
          end
        else
puts">>>>>> monthly_working_application : else"
        end
      end
    end
  end
  
  #週報を承認
  def do_change_weekly_report_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login)
    end
  end
  
  #経費申請を承認
  def do_change_expense_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login)
    end
  end

  #経費申請を承認
  def do_change_payment_per_month_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login)
    end
  end

  #経費申請を承認
  def do_change_payment_per_case_app(application_approval_id, approval_status_type)
    ActiveRecord::Base::transaction do
      application_approval = update_approval_status_type(application_approval_id, approval_status_type)
      application_approval.base_application.change_approval_status(current_user.login)
    end
  end

  # 申請ステータスを更新した時のメッセージを生成して返す
  def approval_status_message(application_type, approval_status_type)
    approval_status = ApplicationApproval.approval_action_str(approval_status_type)
    "#{approval_status}しました。"
  end

end
