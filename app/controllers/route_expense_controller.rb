class RouteExpenseController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @route_expense_pages, @route_expenses = paginate :route_expenses, :per_page => 10, :conditions => "deleted = 0 "
  end

  def show
    @route_expense = RouteExpense.find(params[:id], :conditions => "deleted = 0 ")
    @route_expense_detail_pages, @route_expense_details = paginate(:route_expense_details, :per_page => 10, :conditions => ["route_expense_id = ? and deleted = 0", @route_expense.id])
  end

  def new
    #@calendar = true
    @route_expense = RouteExpense.new
    #employee = Employee.find(params[:employee_id])
    @route_expense.user_id = params[:id]
  end

  def create
    parseTimes(params)
    @route_expense = RouteExpense.new(params[:route_expense])
    if @route_expense.save
      flash[:notice] = 'RouteExpense was successfully created.'
      #if @route_expense.active_flg == 1
        redirect_to :action => 'show', :id => @route_expense
      #else
      #  redirect_to :controller => 'employee', :action => 'list'
      #end
    else
      render :action => 'new'
    end
  end

  def edit
    @calendar = true
    @route_expense = RouteExpense.find(params[:id], :conditions => "deleted = 0 ")
  end

  def update
    parseTimes(params) 
    @route_expense = RouteExpense.find(params[:id], :conditions => "deleted = 0 ")
    @route_expense.attributes = params[:route_expense]
    #if @route_expense.update_attributes(params[:route_expense])
    if @route_expense.save
      flash[:notice] = 'RouteExpense was successfully updated.'
      if @route_expense.active_flg == 1
        redirect_to :action => 'show', :id => @route_expense
      else
        redirect_to :controller => 'account', :action => 'list'
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    #RouteExpense.find(params[:id]).destroy
    route_expense = RouteExpense.find(params[:id], :conditions => "deleted = 0 ")
    route_expense.deleted = 9
    route_expense.save!
    redirect_to :action => 'list'
  end
end
