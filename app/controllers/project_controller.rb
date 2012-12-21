class ProjectController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @project_pages, @projects = paginate :projects, :conditions =>["deleted = 0"], :per_page => current_user.per_page
  end

  # プロジェクトの基本画面
  # プロジェクト指定の月別人別一覧
  def show
    @project = Project.find(params[:id], :conditions => "deleted = 0")
    # 人別月別のマップを作成する
    @map = Hash.new
    @sum_member = Hash.new
    @sum_month = Hash.new
    @sum_total = 0
    @project.members.each do |member|
      @map[member.id] = Hash.new unless @map[member.id]
    end
    @project.personal_sales.each do |personal_sale|
      @map[personal_sale.user_id] = Hash.new unless @map[personal_sale.user_id]
      amount = personal_sale.send('planed_sales_amount').to_i / 10000
      @map[personal_sale.user_id][personal_sale.base_month_id] = amount
      @sum_member[personal_sale.user_id] = @sum_member[personal_sale.user_id].to_f + amount
      @sum_month[personal_sale.base_month_id] = @sum_month[personal_sale.base_month_id].to_f + amount
      @sum_total += amount
    end
  end

  def new
    @calendar = true
    @project = Project.new
    @pic_select_items = User.pic_select_items
    @business_partner_select_items = BusinessPartner.find(:all, :conditions => "deleted = 0").collect{|x| [x.business_partner_name, x.id] }
  end

  def create
    parseCurrency params
    @project = Project.new(params[:project])
    set_user_column @project
    @project.save!
    flash[:notice] = 'Project was successfully created.'
    redirect_to :action => 'list'
  rescue ActiveRecord::RecordInvalid
    @calendar = true
    @pic_select_items = User.pic_select_items
    @business_partner_select_items = BusinessPartner.find(:all, :conditions => "deleted = 0").collect{|x| [x.business_partner_name, x.id] }
    render :action => 'new'
  end

  def edit
    @calendar = true
    @project = Project.find(params[:id])
    @pic_select_items = User.pic_select_items
    @business_partner_select_items = BusinessPartner.find(:all, :conditions => "deleted = 0").collect{|x| [x.business_partner_name, x.id] }
  end

  def update
    parseCurrency params
    @project = Project.find(params[:id], :conditions =>["deleted = 0"])
    @project.attributes = params[:project]
    set_user_column @project
    @project.save!
    flash[:notice] = 'Project was successfully updated.'
    redirect_to :action => 'show', :id => @project
  rescue ActiveRecord::RecordInvalid
    @calendar = true
    @pic_select_items = User.pic_select_items
    @business_partner_select_items = BusinessPartner.find(:all, :conditions => "deleted = 0").collect{|x| [x.business_partner_name, x.id] }
    render :action => 'edit'
  end

  def destroy
    @project = Project.find(params[:id], :conditions =>["deleted = 0"])
    @project.deleted = 9
    set_user_column @project
    @project.save!
    
    redirect_to :action => 'list'
  end

  def set_detail
    @project = Project.find(params[:id], :conditions =>["deleted = 0"])
    @base_month = BaseMonth.find(params[:base_month], :conditions =>["deleted = 0"])
    @user = User.find(params[:user], :conditions =>["deleted = 0"])
    @personal_sale = PersonalSale.find(:first, :conditions => ["deleted = 0 and project_id = ? and base_month_id = ? and user_id = ?", @project.id, @base_month.id, @user.id])
    @personal_sale ||= PersonalSale.new
    @personal_sale.project_id = @project.id
    @personal_sale.base_month_id = @base_month.id
    @personal_sale.user_id = @user.id
    if request.post?
      @personal_sale.attributes = params[:personal_sale]
      set_user_column @personal_sale
      @personal_sale.save!
      flash[:notice] = '明細の更新に成功しました'
      redirect_to(params[:back_to] || {:action => 'list'})
    end
  rescue ActiveRecord::RecordInvalid
  end

  def summary
    today = Date.today
    @min_date = today - 6.month
    @max_date = today + 6.month

    sql1 = <<-EOS
      select a.id, sum(planed_sales_amount) as planed_sales_amount, sum(sales_amount) as sales_amount
      from base_months a
      join personal_sales b on a.id = b.base_month_id
      where a.deleted = 0 and b.deleted = 0 and a.start_date >= ? and a.start_date <= ?
      group by a.id
      order by a.id
    EOS
    @sum_by_months = BaseMonth.find_by_sql([sql1, @min_date, @max_date])

    sql2 = <<-EOS
      select b.base_month_id, b.user_id, sum(planed_sales_amount) as planed_sales_amount, sum(sales_amount) as sales_amount
      from base_months a
      join personal_sales b on a.id = b.base_month_id
      where a.deleted = 0 and b.deleted = 0 and a.start_date >= ? and a.start_date <= ?
      group by b.base_month_id, b.user_id
      order by b.base_month_id, b.user_id
    EOS
    @sum_by_users = BaseMonth.find_by_sql([sql2, @min_date, @max_date])

    @base_months = BaseMonth.find(:all, :conditions => ["deleted = 0 and start_date >= ? and start_date <= ?", @min_date, @max_date], :order => "start_date")
    @month_total = Hash.new
    @map = Hash.new
    @plan_month_total = Hash.new
    @plan_map = Hash.new
    @base_months.each{|base_month|
      @month_total[base_month.id] = 0
      @plan_month_total[base_month.id] = 0
    }
    @sum_by_users.each{|sum|
      amount = sum.send('sales_amount').to_i
      @month_total[sum.base_month_id.to_i] += amount
      @map[sum.user_id.to_i] ||= Hash.new
      @map[sum.user_id.to_i][sum.base_month_id.to_i] = amount

      plan_amount = sum.send('planed_sales_amount').to_i
      @plan_month_total[sum.base_month_id.to_i] += plan_amount
      @plan_map[sum.user_id.to_i] ||= Hash.new
      @plan_map[sum.user_id.to_i][sum.base_month_id.to_i] = plan_amount
    }

    sql3 = <<-EOS
      select b.base_month_id, b.project_id, sum(planed_sales_amount) as planed_sales_amount, sum(sales_amount) as sales_amount
      from base_months a
      join personal_sales b on a.id = b.base_month_id
      where a.deleted = 0 and b.deleted = 0 and a.start_date >= ? and a.start_date <= ?
      group by b.base_month_id, b.project_id
      order by b.base_month_id, b.project_id
    EOS
    @sum_by_projects = BaseMonth.find_by_sql([sql3, @min_date, @max_date])

    @project_map = Hash.new
    @project_plan_map = Hash.new
    @sum_by_projects.each{|sum|
      amount = sum.send('sales_amount').to_i
      @project_map[sum.project_id.to_i] ||= Hash.new
      @project_map[sum.project_id.to_i][sum.base_month_id.to_i] = amount

      plan_amount = sum.send('planed_sales_amount').to_i
      @project_plan_map[sum.project_id.to_i] ||= Hash.new
      @project_plan_map[sum.project_id.to_i][sum.base_month_id.to_i] = plan_amount
    }

  end

end
