class MerchantController < ApplicationController
  protect_from_forgery :except => [:redeemVocuher]
  before_filter :check_user, :except => [:login]
  
  def new_index
    @deals = Deal.all(:company_id => session[:company_id])
    
  end
  
  def index
    @deals = Deal.all(:company_id => session[:company_id])
    if params[:deal_id] == nil || params[:deal_id] == 'all'
      @vouchers = Voucher.all(:status => 'active', :company_id => session[:company_id])
    else
      @vouchers = Voucher.all(:status => 'active', :company_id => session[:company_id], :deal_id => params[:deal_id])
    end
  end
  
  def redeemVocuher
    voucher = Voucher.where(:id => params[:id], :status => 'active', :company_id => params[:company_id]).first
    if voucher != nil
      voucher.update_attributes(:status => 'redeemed')
      status = 'success'
    else
      status = 'fail'
    end
    respond_to do |format|
      format.json { render :json => '{"status": "' + status + '"}' }
    end
  end
  
  def add_customers
    @vouchers = Voucher.all
    for v in @vouchers
      customer = Customer.find(v.customer_id)
      v.customer_first_name = customer.first_name
      v.customer_last_name = customer.last_name
      v.save
    end
    redirect_to(:action => 'index')
  end
  
  def addcomp
    vouchers = Voucher.all()
    for v in vouchers
      v.company_id = v.deal.company_id
      v.save
    end
    redirect_to(:action => 'index')
  end
  
  # Login
  
  def login
    if params[:company] != nil
      session[:company_id] = tryToLogin(params[:company][:username], params[:company][:password])
      if session[:company_id] != nil
        redirect_to(:action => 'index')
      else
        flash[:error] = 'Username or Password incorrect'
        redirect_to(:action => 'login')
      end
    end 
  end
  
  private
  
  def check_user
    if session[:company_id] == nil
      redirect_to(:action => 'login')
    end
  end
  
  def tryToLogin(username, password)
    logged_in_user = Company.authenticate(username, password)
    if logged_in_user != nil
      return logged_in_user
    else
      return nil
    end
  end
  
end
