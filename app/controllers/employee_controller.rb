class EmployeeController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1])
  end
  
  def address_list
    list
    render :action => 'list'
  end
  
  def order_by_birthday_asc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'birthday_date')
    render :action => 'list'
  end
  
  def order_by_birthday_desc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'birthday_date desc')
    render :action => 'list'
  end
  
  def order_by_entry_date_asc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'entry_date')
    render :action => 'list'
  end
  
  def order_by_entry_date_desc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'entry_date desc')
    render :action => 'list'
  end
  
  def order_by_zip1_asc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'zip1')
    render :action => 'list'
  end
  
  def order_by_zip1_desc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'zip1 desc')
    render :action => 'list'
  end
  
  def order_by_tel1_asc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'tel1')
    render :action => 'list'
  end
  
  def order_by_tel1_desc
    @employee_pages, @employees = paginate(:employees, :per_page => 50, :conditions => ["active_flg = ? and deleted = 0", 1], :order => 'tel1 desc')
    render :action => 'list'
  end
  
  def show
    @employee = Employee.find(params[:id], :conditions => "deleted = 0 ")
  end

  def new
    @calendar = true
    @employee = Employee.new
    @users = User.find(:all, :conditions => "deleted = 0 ", :order => "id") 
    @departments = Department.find(:all, :conditions => "deleted = 0 ", :order => "display_order") 
  end

  def create
    parseTimes(params)
    @employee = Employee.new(params[:employee])
    #upload file
    if params[:upload]['file1'] != ""
      file1 = params[:upload]['file1']
      xxx = rand(1000000).to_s
      filename1 = "employee_#{@employee.user_id}_#{xxx}" + "." + (file1.original_filename.to_s).split('.')[1]
      @employee.attached_file1 = filename1
      File.open("public/images/#{filename1}", "wb"){ |f| f.write(file1.read) }
    end
    #if params[:upload]['file3'] != ""
    #  file3 = params[:upload]['file3']
    #  xxx = rand(1000000).to_s
    #  filename3 = "employee_#{@employee.user_id}_#{xxx}" + "." + (file3.original_filename.to_s).split('.')[1]
    #  @employee.attached_file3 = filename3
    #  File.open("public/images/#{filename3}", "wb"){ |f| f.write(file3.read) }
    #end
    
    if @employee.save
      flash[:notice] = 'Employee was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
    
  end

  def edit
    @calendar = true
    @employee = Employee.find(params[:id], :conditions => "deleted = 0 ")
    
    @users = User.find(:all, :conditions => "deleted = 0 ", :order => "id") 
    @departments = Department.find(:all, :order => "display_order")
  end
  
  def edit_bank
    @employee = Employee.find(params[:id], :conditions => "deleted = 0 ")
  end

  def update
    parseTimes(params)
    @employee = Employee.find(params[:id], :conditions => "deleted = 0 ")
    
    #copy employee object
    #@employee_new = @employee.clone
    #@employee_new.attributes = params[:employee] 
    
    @employee.attributes = params[:employee] 
    
    #upload file
    if params[:upload]['file1'] != ""
      file1 = params[:upload]['file1']
      xxx = rand(1000000).to_s
      filename1 = "employee_#{@employee.user_id}_#{xxx}" + "." + (file1.original_filename.to_s).split('.')[1]
      @employee.attached_file1 = filename1
      #@employee_new.attached_file1 = filename1
      File.open("public/images/#{filename1}", "wb"){ |f| f.write(file1.read) }
    end
    #if params[:upload]['file3'] != ""
    #  file3 = params[:upload]['file3']
    # xxx = rand(1000000).to_s
    #  filename3 = "employee_#{@employee.user_id}_#{xxx}" + "." + (file3.original_filename.to_s).split('.')[1]
    #  @employee.attached_file3 = filename3
    #  File.open("public/images/#{filename3}", "wb"){ |f| f.write(file3.read) }
    #end
    
    #update active flg
    #@employee.active_flg = 0
    #@employee_new.active_flg = 1
    #if @employee.save && @employee_new.save
    
    if @employee.save
      flash[:notice] = 'Employee was successfully updated.'
      redirect_to :action => 'show', :id => @employee
      #redirect_to :action => 'show', :id => @employee_new
    else
      render :action => 'edit'
    end
  end
  
  def update_bank
    @employee = Employee.find(params[:id], :conditions => "deleted = 0 ")
    @employee.attributes = params[:employee] 
    if @employee.save
      flash[:notice] = 'Employee was successfully updated.'
      redirect_to :action => 'show', :id => @employee
    else
      render :action => 'edit'
    end
  end

  def destroy
    #Employee.find(params[:id]).destroy
    employee = Employee.find(params[:id], :conditions => "deleted = 0 ")
    employee.deleted = 9
    employee.save!
    redirect_to :action => 'list'
  end
end
