class ManageController < ApplicationController
  
  #before_filter :check_status, :except => [:login]
  
  def login
    if params[:admin] != nil
      session[:admin] = Admin.authenticate(params[:admin][:email], params[:admin][:password])
      return redirect_to(:action => 'admins')
    end
  end
  
  def logout
    session[:admin] = nil
    redirect_to("/")
  end
  
  #
  # Admins
  #
  
  def admins
    @admins = Admin.all
  end
  
  def add_admin
    if params[:admin]!=nil
      Admin.create!(params[:admin])
      redirect_to(:action => 'admins')
    end
  end
  
  def edit_admin
    @admin = Admin.find(params[:id])
    if params[:admin]!=nil
      @admin.update_attributes(params[:admin])
      redirect_to(:action => 'admins')
    end
  end
  
  def destroyAdmin
    admin = Admin.find(params[:id])
    if admin != nil
      admin.destroy
    end
    redirect_to(:action => 'admins')
  end
  
  #
  # Companies
  #
  
  def all_companies
    @companies = Company.all()
  end
  
  def add_company
    if params[:company] != nil
      company = Company.new(params[:company])
      numberOfLocations = 0
      params[:numberOfLocations].to_i.times do
        numberOfLocations+=1
        location = StoreLocation.new(params["#{numberOfLocations.to_s.to_sym}"])
        company.store_locations << location
      end
      company.save
      redirect_to(:action => 'all_companies')
    end
  end
  
  def company
    @company = Company.find(params[:id])
  end
  
  def edit_company
    @company = Company.find(params[:id])
    if params[:company] != nil
      @company.update_attributes(params[:company])
      for l in @company.store_locations
        l.update_attributes(params["#{l.id.to_s.to_sym}"])
      end
      numberOfLocations = 0
      params[:numberOfLocations].to_i.times do
        numberOfLocations+=1
        location = StoreLocation.new(params["#{numberOfLocations.to_s.to_sym}"])
        @company.store_locations << location
      end
      @company.save
      if params[:new][:password] != '' || params[:new][:password] != nil
        @company.new_password = params[:new][:password]
        @company.save
      end
      redirect_to(:action => 'company', :id => @company.id)
    end
  end
  
  def deleteCompanyLocation
    @company = Company.find(params[:id])
    @company.store_locations.delete_if{|s| s.id.to_s == params[:store_id].to_s}
    @company.save
    redirect_to(:action => 'company', :id => @company.id)
  end
  
  #
  # Areas
  #
  
  def locations
    @areas = Area.paginate(:per_page => 20, :page => params[:page], :hide.ne => 1)
  end
  
  def addArea
    if params[:area] != nil
      Area.create!(params[:area])
    end
    redirect_to(:action => 'locations')
  end
  
  def editArea
    @area = Area.find(params[:id])
    if params[:area] != nil
      @area.update_attributes(params[:area])
      redirect_to(:action => 'locations')
    end
  end
  
  def deleteArea
    a = Area.find(params[:id])
    a.hide = 1
    a.save
    redirect_to(:action => 'locations')
  end
  
  #
  # Deals
  #
  
  def all_deals
    @deal = Deal.paginate(:per_page => 20, :page => params[:page])
  end
  
  def add_deal
    @company = Company.find(params[:id])
    if params[:deal] != nil
      deal = Deal.new(params[:deal])
      deal.start_date = ("#{params[:start]['date(1i)']}-#{params[:start]['date(2i)']}-#{params[:start]['date(3i)']}").to_time
      deal.end_date = ("#{params[:end]['date(1i)']}-#{params[:end]['date(2i)']}-#{params[:end]['date(3i)']}").to_time
      deal.company_id = @company.id
      locations = []
      locs = params[:selectedlocations].split(',')
      for l in locs
        locations.push(l)
      end
      deal.locations = locations
      deal.save
      @company.recount_deals
      redirect_to(:action => 'company', :id => @company.id)
    end
  end
  
  def edit_deal
    @deal = Deal.find(params[:id])
    @company = Company.find(@deal.company_id)
    if params[:deal] != nil
      @deal.start_date = ("#{params[:start]['date(1i)']}-#{params[:start]['date(2i)']}-#{params[:start]['date(3i)']}").to_time
      @deal.end_date = ("#{params[:end]['date(1i)']}-#{params[:end]['date(2i)']}-#{params[:end]['date(3i)']}").to_time
      @deal.locations.clear
      @deal.save
      locs = params[:selectedlocations].split(',')
      for l in locs
        @deal.locations << l
      end
      @deal.update_attributes(params[:deal])
      if params[:upload] != nil
        if params[:upload][:home] != nil
          @deal.upload_photos('home', params[:upload])
        end
        if params[:upload][:weekly] != nil
          @deal.upload_photos('weekly', params[:upload])
        end
        if params[:upload][:hero] != nil
          @deal.upload_photos('hero', params[:upload])
        end
      end
      @company.recount_deals
      #redirect_to(:action => 'deal', :id => @deal.id)
    end
  end
  
  def cancel_deal
    deal = Deal.find(params[:id])
    deal.status = 'cancelled'
    deal.save
    redirect_to(:action => 'all_deals')
  end
  
  def destroy_deal
    Deal.find(params[:id]).destroy
    redirect_to(:action => 'all_deals')
  end
  
  def deal
    @deal = Deal.find(params[:id])
    @company = Company.find(@deal.company_id)
  end
  
  #
  # Customers
  # 
  
  def all_customers
    @customers = Customer.paginate(:page => params[:page], :per_page => 25)
  end
  
  def view_customer
    @customer = Customer.find(params[:id])
    @vouchers = Voucher.all(:customer_id => params[:id])
  end
  
  def edit_customer
    @customer = Customer.find(params[:id])
    if params[:customer] != nil
      @customer.update_attributes(params[:customer])
      redirect_to(:action => 'view_customer', :id => params[:id])
    end
  end
  
  def destroy_customer
    customer = Customer.find(params[:id])
    customer.destroy
    redirect_to(:action => 'all_customers')
  end
  
  #
  # Newsletter
  #
  
  def testsenddelay
    10.times do
      puts Time.now
      sleep 0.35
    end
  end
  
  def send_newsletter
    customers = Customer.all.reverse
    deals = Deal.where(:status.nin => ['pending', 'cancelled'])
    featured = Deal.first(:status => 'featured')
    sleeper = 10.00
    for c in customers
      if c.email != nil && c.email != ''
        c.sendNewsletter(sleeper, deals, featured)
        sleeper += 0.40
      end
    end
    redirect_to(:action => 'all_customers')
  end
  
  def fixeamils
    customers = Customer.all
    for c in customers
      if c.email.include?(' ')
        c.email = c.email.gsub(' ', '.')
        c.save
      end
    end
  end
  
  #
  # test
  #
  
  def addInitialAdmin
    user = Admin.new()
  end
  
  def add_company_to_deal
    deals = Deal.all
    for d in deals
      d.company_name = Company.find(d.company_id).name
      d.save
    end
    redirect_to(:action => 'all_customers')
  end
  
  private
  
  def check_status
    if session[:admin] == nil
      redirect_to(:action => 'login')
    end
  end
  
  
end
