class PersonalSaleController < ApplicationController

  def index
    list
    render :action => 'list'
  end



  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @personal_sale_pages, @personal_sales = paginate :personal_sales, :conditions =>["deleted = 0"], :per_page => current_user.per_page
  end

  def show
    @personal_sale = PersonalSale.find(params[:id])
  end

  def new
    @personal_sale = PersonalSale.new
  end

  def create
    @personal_sale = PersonalSale.new(params[:personal_sale])
    set_user_column @personal_sale
    @personal_sale.save!
    flash[:notice] = 'PersonalSale was successfully created.'
    redirect_to :action => 'list'
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def edit
    @personal_sale = PersonalSale.find(params[:id])
  end

  def update
    @personal_sale = PersonalSale.find(params[:id], :conditions =>["deleted = 0"])
    @personal_sale.attributes = params[:personal_sale]
    set_user_column @personal_sale
    @personal_sale.save!
    flash[:notice] = 'PersonalSale was successfully updated.'
    redirect_to :action => 'show', :id => @personal_sale
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  def destroy
    @personal_sale = PersonalSale.find(params[:id], :conditions =>["deleted = 0"])
    @personal_sale.deleted = 9
    set_user_column @personal_sale
    @personal_sale.save!
    
    redirect_to :action => 'list'
  end
end
