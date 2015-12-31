class MobileController < ApplicationController
  protect_from_forgery :except => [:login]
  
  # Pages
  
  def index
    @deals = Deal.where(:status.nin => ['pending', 'cancelled'])
    @heading = '<div data-role="header"><img src="/assets/mobile_logoChris.png" onclick="$.mobile.changePage( \'#HomePage\', { transition: \'fade\'});" height="50"><div class="logoutButton" style="float:right;padding-right:20px;"><input value="Log Out" type="button" onclick="logout();"></div></div>'
    @mapcache = MapCache.getCache
    @areas = Area.all(:hide.ne => 1)
  end
  
  def setFeaduredDeal
    featured_deal = Deal.first(:status => 'featured')
    if featured_deal != nil
      featured = featured_deal
    else
      featured = Deal.first(:status => 'active')
    end
    respond_to do |format|
      format.json { render :json => featured.to_json }
    end
  end
  
  def getDeal
    deal = Deal.find(params[:id])
    locations = Company.find(deal.company_id).store_locations
    locs = []
    for l in locations
      if deal.locations.include?(l.id.to_s)
        locs << l
      end
    end
    respond_to do |format|
      format.json { render :json => '{"dealData": ' + deal.to_json + ', "locations": ' + locs.to_json + '}' }
    end
  end
  
  def getDealsData
    respond_to do |format|
      format.json { render :json => (Deal.where(:status.nin => ['pending', 'cancelled']).fields(:id, :home, :headline, :cost, :retail, :company_name, :area_id)).to_json }
    end
  end
  
  def getDealMap
    respond_to do |format|
      format.json { render :json => (MapCache.getCache).to_json }
    end
  end
  
  def updateMyDeals
    vouchers = Voucher.where(:customer_id => params[:id]).fields(:id, :deal_id)
    deals = Deal.where(:id.in => vouchers.map(&:deal_id)).fields(:id, :retail, :cost, :headline, :description, :fine_print, :company_name)
    deals_json = ''
    for d in deals
      deals_json << ',{"id" : "' + d.id.to_s + '", "retail" : "' + d.retail.to_s + '", "cost" : "' + d.cost.to_s + '", "headline": "' + URI::escape(d.headline.to_s) + '", "description" : "' + URI::escape(d.description.to_s) + '", "fine_print" : "' + URI::escape(d.fine_print.to_s) + '", "company_name" : "' + d.company_name + '"}'
    end
    deals_json[0] = ''
    respond_to do |format|
      format.json { render :json => '{"deals": [' + deals_json + '], "vouchers": ' + vouchers.to_json + '}' }
    end
  end
  
  def refreshUserData
    respond = Customer.find(params[:id])
    if respond != nil
      cards = []
      for c in respond.credit_cards
        cards << '{"last_four": "' + c.last_four + '", "id" : "' + c.id + '"}'
      end
      re = '{"status": "success", "user_id": "' + respond.id + '", "name": "' + respond.full_name + '", "cards" : ' + cards.to_s + '}'
    else
      re = '{"status": "fail"}'
    end
    respond_to do |format|
      format.json { render :json => re }
    end
  end
  
  def viewDeal
    @deal = Deal.find(params[:id])
    @locations = Company.find(@deal.company_id).store_locations
  end
  
  # Login/Register
  def login
    respond = tryToLogin(params[:username], params[:password])
    if respond != nil
      cards = []
      for c in respond.credit_cards
        cards << '{"last_four": "' + c.last_four + '", "id" : "' + c.id + '"}'
      end
      re = '{"status": "success", "user_id": "' + respond.id + '", "name": "' + respond.full_name + '", "cards" : ' + cards.to_s + '}'
    else
      re = '{"status": "fail"}'
    end
    respond_to do |format|
      format.json { render :json => re }
    end
  end
  
  def registerAccount
    if Customer.find_by_email(params[:email]) == nil
      customer = Customer.new(:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email], :new_password => params[:password])
      if customer.save
        re = '{"status": "success", "user_id": "' + customer.id + '", "name": "' + customer.full_name + '"}'
      else
        re = '{"status": "fail", "reason": "Error creating account"}'
      end
    else
      re = '{"status": "fail", "reason": "A user with this email already exist"}'
    end
    respond_to do |format|
      format.json { render :json => re }
    end
  end
  
  # Purchase API
  
  def confirmPurchaseold
    deal = Deal.find(params[:id])
    customer = Customer.find(params[:user_id])
    voucher = Voucher.createVoucher(deal.id, customer.id)
    if voucher == 'purchased' || voucher == nil
      # error this voucher is already purchased
      error = "I'm Sorry #{customer.first_name}, You can not purchase #{params[:deal_qty]} more of this deal. It would be more than the maximum allowed qty of #{deal.max_per_customer.to_i}"
    else
      if params[:ccgroup] != 'new_card'
        card = CreditCard.find(params[:ccgroup])
      else
        card_info = {'number' => params[:card_number], 'month' => params[:card_month], 'year' => params[:card_year], 'cvv' => params[:card_cvv], 'name' => params[:card_name], 'address' => params[:card_address], 'city' => params[:card_city], 'state' => params[:card_state], 'zip' => params[:card_zip] }
        card = CreditCard.create_card(card_info, customer.id)
      end
      if card == nil
        # error with CC
        error = "I'm Sorry #{customer.first_name}, there is a problem with your credit card."
      else
        response = card.chargeCreditCard(customer.first_name, customer.last_name, deal.cost)
        if response['status'] == 'fail'
           # Card Declined
           error = "I'm Sorry #{customer.first_name}, There was a problem charging your card."
        else
          if params[:aff] != nil && params[:aff] != ''
            voucher.markPurchased(params[:aff])
          else
            voucher.markPurchased(nil)
          end
        end
      end
    end
    if error != nil
      respond = '{"status" : "fail", "reason" : "' + error + '"}'
    else
      respond = '{"status" : "success", "dealData" : [' + voucher.to_json + ']}'
    end
    puts respond
    respond_to do |format|
      format.json { render :json => respond }
    end
  end
  
  def testJson
    respond_to do |format|
      format.json { render :json => data }
    end
  end
  
  def confirmPurchase
    deal = Deal.find(params[:id])
    customer = Customer.find(params[:user_id])
    vouchers = Voucher.createVouchers(deal.id, customer.id, params[:qty])
    # Has this voucher already been purchased?
    if vouchers == 'purchased'
      error = "I'm Sorry #{customer.first_name}, You can not purchase this qty."
    else
      # Add Credit Card Info
      if params[:ccgroup] != 'new_card'
        card = CreditCard.find(params[:ccgroup])
      else
        card_info = {'number' => params[:card_number], 'month' => params[:card_month], 'year' => params[:card_year], 'cvv' => params[:card_cvv], 'name' => params[:card_name], 'address' => params[:card_address], 'city' => params[:card_city], 'state' => params[:card_state], 'zip' => params[:card_zip] }
        card = CreditCard.create_card(card_info, customer.id)
      end
      # Check if card is good
      if card == nil
        error = "I'm Sorry #{customer.first_name}, there is a problem with your credit card."
      else
        # Try to process payment
        if VoucherPayment.processPaymentNew(1, (deal.cost.to_i*params[:qty].to_i), card.id, vouchers) == false
          error = "I'm sorry, It seems your credit card has declined."
        else
          customer.addAddressData(params[:card_address], params[:card_city], params[:card_state], params[:card_zip])
          for v in vouchers
            v.markPurchased(params[:aff])
          end
        end
      end
    end
    if error != nil
      respond = '{"status" : "fail", "reason" : "' + error + '"}'
    else
      respond = '{"status" : "success"}'
    end
    respond_to do |format|
      format.json { render :json => respond }
    end
  end
  
  def confirmPurchase2
    deal = Deal.find(params[:id])
    customer = Customer.find(params[:user_id])
    voucher = Voucher.createVoucher(deal.id, customer.id)
    # Has this voucher already been purchased?
    if voucher == 'purchased'
      error = "I'm Sorry #{customer.first_name}, You have already purchased this deal."
    else
      # Add Credit Card Info
      if params[:ccgroup] != 'new_card'
        card = CreditCard.find(params[:ccgroup])
      else
        card_info = {'number' => params[:card_number], 'month' => params[:card_month], 'year' => params[:card_year], 'cvv' => params[:card_cvv], 'name' => params[:card_name], 'address' => params[:card_address], 'city' => params[:card_city], 'state' => params[:card_state], 'zip' => params[:card_zip] }
        card = CreditCard.create_card(card_info, customer.id)
      end
      # Check if card is good
      if card == nil
        error = "I'm Sorry #{customer.first_name}, there is a problem with your credit card."
      else
        # Try to process payment
        if VoucherPayment.processPayment(1, deal.cost, card.id, voucher.id) == false
          error = "I'm sorry, It seems your credit card has declined."
        else
          customer.addAddressData(params[:card_address], params[:card_city], params[:card_state], params[:card_zip])
          voucher.markPurchased(params[:aff])
        end
      end
    end
    if error != nil
      respond = '{"status" : "fail", "reason" : "' + error + '"}'
    else
      respond = '{"status" : "success", "dealData" : [' + voucher.to_json + ']}'
    end
    respond_to do |format|
      format.json { render :json => respond }
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
      return logged_in_user
    else
      return nil
    end
  end
  
end