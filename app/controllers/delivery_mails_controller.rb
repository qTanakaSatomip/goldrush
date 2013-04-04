# -*- encoding: utf-8 -*-
class DeliveryMailsController < ApplicationController
  # GET /delivery_mails
  # GET /delivery_mails.json
  def index
    @delivery_mails = DeliveryMail.page(params[:page]).per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @delivery_mails }
    end
  end

  # GET /delivery_mails/1
  # GET /delivery_mails/1.json
  def show
    @delivery_mail = DeliveryMail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @delivery_mail }
    end
  end

  # GET /delivery_mails/new
  # GET /delivery_mails/new.json
  def new
    @select_options = []
    for num in 0..23
      @select_options.push([num, num])
    end
    @delivery_mail = DeliveryMail.new
    @delivery_mail.bp_pic_group_id = params[:id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @delivery_mail }
    end
  end

  # GET /delivery_mails/1/edit
  def edit
    @delivery_mail = DeliveryMail.find(params[:id])
  end

  # POST /delivery_mails
  # POST /delivery_mails.json
  def create
    @delivery_mail = DeliveryMail.new(params[:delivery_mail])
    @delivery_mail.bp_pic_group_id = params[:bp_pic_group_id]
    
    respond_to do |format|
      begin
        @delivery_mail.save!
        format.html { redirect_to :controller => 'bp_pic_groups', :action => 'show', :id => 1, notice: 'Delivery mail was successfully created.' }
        format.json { render json: @delivery_mail, status: :created, location: @delivery_mail }
      rescue ActiveRecord::RecordInvalid
        format.html { render action: "new" }
        format.json { render json: @delivery_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /delivery_mails/1
  # PUT /delivery_mails/1.json
  def update
    @delivery_mail = DeliveryMail.find(params[:id])

    respond_to do |format|
      begin
        @delivery_mail.update_attributes!(params[:delivery_mail])
        format.html { redirect_to @delivery_mail, notice: 'Delivery mail was successfully updated.' }
        format.json { head :no_content }
      rescue ActiveRecord::RecordInvalid
        format.html { render action: "edit" }
        format.json { render json: @delivery_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_mails/1
  # DELETE /delivery_mails/1.json
  def destroy
    @delivery_mail = DeliveryMail.find(params[:id])
    @delivery_mail.destroy

    respond_to do |format|
      format.html { redirect_to delivery_mails_url }
      format.json { head :no_content }
    end
  end
end
