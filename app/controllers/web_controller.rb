class WebController < ApplicationController
  
  before_filter :check_mobile
  
  def splash
    if params[:customer] != nil
      customer = Customer.new(params[:customer])
      customer.save
      session[:user] = {'user_id' => customer.id, 'full_name' => customer.full_name}
      return redirect_to(:action => 'thank_you')
    end
    render :layout => false
  end
  
  def thank_you
    render :layout => false
  end
  
  def index  
    if params[:filter] != nil
      if params[:max_price].blank?
        max_price = 9999999
      else
        max_price =  params[:max_price].gsub('$', '').to_i
      end
      if params[:area_id] == 'all'
        area = ''
      else
        area = ", :area_id => '#{params[:area_id]}'"
      end
      eval("@deals = Deal.where(:status.nin => ['pending', 'cancelled'], :cost.lte => #{max_price}#{area})")
    else
      @deals = Deal.where(:status.nin => ['pending', 'cancelled'])
    end
  end
  
  def deal
    @deal = Deal.find(params[:id])
    @locations = Company.find(@deal.company_id).store_locations
  end
  
  #
  # Login
  #
  
  def login
    if params[:user] != nil
      session[:user] = tryToLogin(params[:user][:email], params[:user][:password])
      return redirect_to(:action => 'index')
    end
    if params[:customer] != nil
      customer = Customer.create!(params[:customer])
      session[:user] = {'user_id' => customer.id, 'full_name' => customer.full_name}
      return redirect_to(:action => 'index')
    end
  end
  
  def register
    customer = Customer.new(params[:customer])
    if customer.save
      session[:user] = {'user_id' => customer.id, 'full_name' => customer.full_name}
      if params[:deal_id] != nil
        return redirect_to(:action => 'purchaseDeal', :id => params[:deal_id])
      else
        return redirect_to(:action => 'index')
      end
    else
      flash[:error] = 'There is already an account associated with this email address'
      if params[:deal_id] != nil
        return redirect_to(:action => 'purchaseDeal', :id => params[:deal_id])
      else
        return redirect_to(:action => 'login')
      end
    end
    
  end
  
  def logout
    session[:user] = nil
    redirect_to(:action => 'index')
  end
  
  #
  # Checkout
  # 
  
  def purchaseDeal
    @deal = Deal.find(params[:id])
    if session[:user] != nil
      @user = Customer.find(session[:user]['user_id'])
      purchased = Voucher.all(:deal_id => @deal.id, :customer_id => @user.id, :status.ne => 'pending').count
      @qty_left = @deal.max_per_customer - purchased
    end
  end
  
  def checkoutLogin
    if params[:user] != nil
      session[:user] = tryToLogin(params[:user][:email], params[:user][:password])
    end
    redirect_to(:action => 'purchaseDeal', :id => params[:id])
  end
  
  def confirmPurchase_old
    deal = Deal.find(params[:id])
    if deal.max_purchases.to_i != 0
      if deal.max_purchases.to_i >= deal.purchases.to_i
        flash[:error] = "This deal has been sold out."
        return redirect_to(:action => 'purchaseDeal', :id => deal.id)
      end
    end
    if session[:user] == nil
      customer = Customer.new(params[:customer])
      customer.address = params[:card][:address]
      customer.city = params[:card][:city]
      customer.state = params[:card][:state]
      customer.zip = params[:card][:zip]
      customer.save
      session[:user] = {'user_id' => customer.id, 'full_name' => customer.full_name}
    else
      customer = Customer.find(session[:user]['user_id'])
    end
    voucher = Voucher.createVoucher(deal.id, customer.id)
    if voucher == 'purchased'
      flash[:error] = "I'm sorry, you have already purchased this deal."
      return redirect_to(:action => 'purchaseDeal', :id => deal.id)
    end
    if params[:ccgroup] != nil
      card = CreditCard.find(params[:ccgroup])
    else
      card_info = {'number' => params[:card][:number], 'month' => params[:card][:month], 'year' => params[:card][:year], 'cvv' => params[:card][:cvv], 'name' => params[:card][:name], 'address' => params[:card][:address], 'city' => params[:card][:city], 'state' => params[:card][:state], 'zip' => params[:card][:zip] }
      card = CreditCard.create_card(card_info, customer.id)
    end
    if card == nil
      flash[:error] = "There is a problem with your credit card. Please check it and try again."
      return redirect_to(:action => 'purchaseDeal', :id => params[:id])
    end
    response = card.chargeCreditCard(customer.first_name, customer.last_name, deal.cost)
    if response['status'] == 'fail'
       flash[:error] = "I'm sorry, It seems your credit card has declined."
       return redirect_to(:action => 'purchaseDeal', :id => deal.id)
     else
      voucher.markPurchased(response['transaction_id'], response['authorization_code'])
      if session[:aff] != nil
        customer.addAffiliateDeal(session[:aff], voucher.id)
      end
      redirect_to(:action => 'myAccount')
    end
  end
  
  def confirmPurchase2
    deal = Deal.find(params[:id])
    customer = Customer.find(session[:user]['user_id'])
    voucher = Voucher.createVoucher(deal.id, customer.id)
    # Check is deal has been purchased already
    if voucher == 'purchased'
      flash[:error] = "I'm sorry, you have already purchased this deal."
      return redirect_to(:action => 'purchaseDeal', :id => deal.id)
    end
    # find the existing card or create a new one
    if params[:ccgroup] != nil
      card = CreditCard.find(params[:ccgroup])
    else
      card_info = {'number' => params[:card][:number], 'month' => params[:card][:month], 'year' => params[:card][:year], 'cvv' => params[:card][:cvv], 'name' => params[:card][:name], 'address' => params[:card][:address], 'city' => params[:card][:city], 'state' => params[:card][:state], 'zip' => params[:card][:zip] }
      card = CreditCard.create_card(card_info, customer.id)
    end
    # Make sure the card saved ok
    if card == nil
      flash[:error] = "There is a problem with your credit card. Please check it and try again."
      return redirect_to(:action => 'purchaseDeal', :id => params[:id])
    end
    # Try to charge the card
    if VoucherPayment.processPayment(1, deal.cost, card.id, voucher.id) == false
      flash[:error] = "I'm sorry, It seems your credit card has declined."
      return redirect_to(:action => 'purchaseDeal', :id => params[:id])
    else
      customer.addAddressData(params[:card][:address], params[:card][:city], params[:card][:state], params[:card][:zip])
      voucher.markPurchased(session[:aff])
      redirect_to(:action => 'myAccount')
    end
  end
  
  def confirmPurchase
    deal = Deal.find(params[:id])
    customer = Customer.find(session[:user]['user_id'])
    vouchers = Voucher.createVouchers(deal.id, customer.id, params[:deal_qty])
    # Check is deal has been purchased already
    if vouchers == 'purchased'
      flash[:error] = "I'm sorry, you can't purhcase this many."
      return redirect_to(:action => 'purchaseDeal', :id => deal.id)
    end
    # find the existing card or create a new one
    if params[:ccgroup] != nil
      card = CreditCard.find(params[:ccgroup])
    else
      card_info = {'number' => params[:card][:number], 'month' => params[:card][:month], 'year' => params[:card][:year], 'cvv' => params[:card][:cvv], 'name' => params[:card][:name], 'address' => params[:card][:address], 'city' => params[:card][:city], 'state' => params[:card][:state], 'zip' => params[:card][:zip] }
      card = CreditCard.create_card(card_info, customer.id)
    end
    # Make sure the card saved ok
    if card == nil
      flash[:error] = "There is a problem with your credit card. Please check it and try again."
      return redirect_to(:action => 'purchaseDeal', :id => params[:id])
    end
    # Try to charge the card
    if VoucherPayment.processPaymentNew(1, (deal.cost.to_f*params[:deal_qty].to_i), card.id, vouchers) == false
      flash[:error] = "I'm sorry, It seems your credit card has declined."
      return redirect_to(:action => 'purchaseDeal', :id => params[:id])
    else
      customer.addAddressData(params[:card][:address], params[:card][:city], params[:card][:state], params[:card][:zip])
      for v in vouchers
        v.markPurchased(session[:aff])
      end
      redirect_to(:action => 'myAccount')
    end
  end
  
  def logout
    session[:user] = nil
    redirect_to('/')
  end
  
  #
  # Client Area
  #
  
  def myAccount
    checkStatus(session[:user])
  end
  
  def editAccount
    checkStatus(session[:user])
    @customer = @user
    if params[:customer] != nil
      @customer.update_attributes(params[:customer])
      return redirect_to(:action => 'myAccount')
    end
  end
  
  def viewCreditCard
    @cc = CreditCard.find(params[:id])
  end
  
  def editCreditCard
    @credit_card = CreditCard.find(params[:id])
    if params[:credit_card] != nil
      @credit_card.update_attributes(params[:credit_card])
      redirect_to(:action => 'viewCreditCard', :id => params[:id])
    end
  end
  
  def purchasedDeal
    @voucher = Voucher.find(params[:id])
    @deal = Deal.find(@voucher.deal_id)
    render :layout => false
  end
  
  def reset_password
    if params[:customer] != nil
      Customer.find_by_email(params[:customer][:email]).reset_password
    end
  end
  
  def resetMyPassword
    if params[:customer] != nil
      customer = Customer.find_by_reset_key(params[:customer][:reset_key])
      if customer != nil
        customer.update_attributes(params[:customer])
        redirect_to(:action => 'login')
      else
        flash[:error] = 'Reset Code Is Incorrect'
        redirect_to(:action => 'resetMyPassword')
      end
    end
  end
  
  #
  # Solutions
  #
  
  def requestInfo
    if params[:lead] != nil
      lead = Lead.create!(params[:lead])
      redirect_to(:action => 'index')
    end
  end
  
  def launch
    users = Customer.all()
    for u in users
      if u.email != '' && u.email != nil && u.email.length >= 3
        NotifiMailer.launch(u).deliver
      end
    end
    redirect_to(:action => 'index')
  end
  
  def fix_deal_counts
    deals = Deal.all
    for d in deals
      vouchers = Voucher.all(:status => 'active', :deal_id => d.id)
      d.purchases = vouchers.count
      d.save
    end
  end
  
  #
  #
   private
  #
  #
  
  def tryToLogin(username, password)
    logged_in_user = Customer.authenticate(username, password)
    if logged_in_user != nil
      return {'user_id' => logged_in_user.id, 'full_name' => logged_in_user.full_name}
    else
      return nil
    end
  end
  
  def checkStatus(user)
    if user == nil
      redirect_to(:action => 'index')
    else
      @user = Customer.find(user['user_id'])
    end
  end
  
  def check_aff
    if params[:aff] != nil
      session[:aff] = params[:aff]
    end
  end
  
  MOBILE_BROWSERS = ["playbook", "windows phone", "android", "ipod", "iphone", "opera mini", "blackberry", "palm", "hiptop", "avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
     agent = request.headers["HTTP_USER_AGENT"].downcase
     MOBILE_BROWSERS.each do |m|
       return "mobile" if agent.match(m)
    end
     return "desktop"
   end
   
   def redirect_to_mobile
     if session[:mobile] != nil
       if session[:mobile] == true
         redirect_to(:controller => 'mobile', :action => 'index')         
       end
     else
       if detect_browser == 'mobile'
         session[:mobile] == true
         return redirect_to(:controller => 'mobile', :action => 'index')   
       else
         session[:mobile] = false
       end
     end
   end
   
   def check_mobile
     check_aff
     if session[:mobile] != true || session[:mobile] == nil
        return redirect_to_mobile
     end
   end
  
end
