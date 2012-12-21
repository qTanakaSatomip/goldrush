class EmployeeHistoryController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @employee = Employee.find(params[:employee_id])
    @employee_history_pages, @employee_histories = paginate(:employee_histories, :per_page => 50, :conditions => ["user_id = ?", @employee.user_id])
    
  end
  
  def show
    @employee_history = EmployeeHistory.find(params[:id])
    @employee = Employee.find(params[:employee_id])
  end

  def new
    @calendar = true
    @employee_history = EmployeeHistory.new
    @employee = Employee.find(params[:employee_id])
    @employee_history.user_id = @employee.user_id
  end

  def create
    parseTimes(params)
    @employee_history = EmployeeHistory.new(params[:employee_history])
    
    if @employee_history.save
      flash[:notice] = 'EmployeeHistory was successfully created.'
      redirect_to :action => 'list', :employee_id => @employee_history.user.employee
    else
      render :action => 'new'
    end
  end

  def edit
    @calendar = true
    @employee_history = EmployeeHistory.find(params[:id])
    @employee = Employee.find(params[:employee_id])
  end

  def update
    parseTimes(params)
    @employee_history = EmployeeHistory.find(params[:id])
    @employee_history.attributes = params[:employee_history] 
    
    if @employee_history.save
      flash[:notice] = 'EmployeeHistory was successfully updated.'
      redirect_to :action => 'show', :id => @employee_history, :employee_id => @employee_history.user.employee
    else
      render :action => 'edit'
    end
  end

  def destroy
    #EmployeeHistory.find(params[:id]).destroy
    employee_history = EmployeeHistory.find(params[:id], :conditions => "deleted = 0 ")
    employee_history.deleted = 9
    employee_history.save!
    @employee = Employee.find(params[:employee_id])
    redirect_to :action => 'list', :employee_id => @employee
  end
end
