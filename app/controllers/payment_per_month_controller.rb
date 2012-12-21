class PaymentPerMonthController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @payment_per_month_pages, @payment_per_months = paginate(:payment_per_months, :per_page => 10, :conditions => ["user_id = ?", current_user.id], :order => "id ")
  end

  def show
    @payment_per_month = PaymentPerMonth.find(params[:id])
  end

  def new
    @calendar = true
    @payment_per_month = PaymentPerMonth.new
  end

  def create
    parseTimes(params)
    @payment_per_month = PaymentPerMonth.new(params[:payment_per_month])
    @payment_per_month.user_id = current_user.id
    if @payment_per_month.save
      flash[:notice] = 'PaymentPerMonth was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @calendar = true
    @payment_per_month = PaymentPerMonth.find(params[:id])
  end

  def update
    parseTimes(params)
    @payment_per_month = PaymentPerMonth.find(params[:id])
    if @payment_per_month.update_attributes(params[:payment_per_month])
      flash[:notice] = 'PaymentPerMonth was successfully updated.'
      redirect_to :action => 'show', :id => @payment_per_month
    else
      render :action => 'edit'
    end
  end

  def destroy
    PaymentPerMonth.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
