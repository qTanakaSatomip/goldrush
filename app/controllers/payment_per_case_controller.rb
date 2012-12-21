class PaymentPerCaseController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @payment_per_case_pages, @payment_per_cases = paginate :payment_per_cases, :per_page => 10
  end

  def show
    @payment_per_case = PaymentPerCase.find(params[:id])
  end

  def new
    @payment_per_case = PaymentPerCase.new
  end

  def create
    @payment_per_case = PaymentPerCase.new(params[:payment_per_case])
    if @payment_per_case.save
      flash[:notice] = 'PaymentPerCase was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @payment_per_case = PaymentPerCase.find(params[:id])
  end

  def update
    @payment_per_case = PaymentPerCase.find(params[:id])
    if @payment_per_case.update_attributes(params[:payment_per_case])
      flash[:notice] = 'PaymentPerCase was successfully updated.'
      redirect_to :action => 'show', :id => @payment_per_case
    else
      render :action => 'edit'
    end
  end

  def destroy
    PaymentPerCase.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
