require 'digest/sha2'
class Customer
	include MongoMapper::Document
	after_create :notifi_email
	
	def notifi_email
	  if self.salt != nil && self.salt != ''
	    NotifiMailer.register(self).deliver
    else
      NotifiMailer.preregister(self).deliver
    end
	end

	# Password Area
  attr_accessor :new_password, :new_password_confirmation
  validates_confirmation_of :new_password, :if => :password_changed?
  before_save :hash_new_password, :if => :password_changed?
      
  def password_changed?
     !@new_password.blank?
  end

  key :first_name, Lowercase, :default => ''
  key :last_name, Lowercase, :default => ''
  key :email, Lowercase, :unique => true
  key :phone, Phone, :default => 0
  key :address, String, :default => ''
  key :city, Lowercase, :default => ''
  key :state, Lowercase, :default => ''
  key :zip, Lowercase, :default => ''
  key :country, Lowercase, :default => ''
  key :points, Integer, :default => 0
  key :affiliate_percentage, Integer, :default => 20


	# Login
  key :salt, String
  key :hashed_password, String
  key :reset_key, String
  key :new_password2, String
  
  # Credit Card Information
  key :encryptedcc, String
  
  # Stats
  key :deals_purchased, Integer, :default => 0
  key :money_saved, Money, :default => 0

  # Associations
  many :vouchers
  many :credit_cards
  many :affiliate_deals
  
  # Helpers
  
  def full_name
    "#{self.first_name.titleize} #{self.last_name.titleize}"
  end
  
  def aff_percent
    self.affiliate_percentage/100.to_f
  end
  
  # update Stats
  
  def update_stats
    self.deals_purchased = Voucher.count(:customer_id => self.id)
    self.money_saved = Voucher.all(:customer_id => self.id).to_a.sum(&:savings)
    self.save
  end
  
  # Affiliates
  
  def addAffiliateDeal(id, voucher_id)
    customer = Customer.find(id)
    voucher = Voucher.find(voucher_id)
    deal = Deal.find(voucher.deal_id)
    if customer != nil && voucher != nil && deal != nil
      affiliate_deal = AffiliateDeal.find(:deal_id => deal.id, :customer_id => customer.id)
      if affiliate_deal == nil
        affiliate_deal = AffiliateDeal.new(:customer_id => customer.id, :deal_id => deal.id, :deals_sold => 0)
      end
      affvoucher = AffiliateVoucher.new()
      affvoucher.amount = deal.cost
      affvoucher.earned = (deal.cost*self.aff_percent)
      affvoucher.voucher_id = voucher.id
      affvoucher.customer_id = voucher.customer_id
      affiliate_deal.affiliate_vouchers << affvoucher
      affiliate_deal.save
      voucher.affiliate_cost = (deal.cost*self.aff_percent)
      voucher.earnings = (deal.cost-(deal.cost*self.aff_percent))
      voucher.save
    end
  end
  
  # Action 
  
  def addAddressData(address, city, state, zip)
    if self.address == ''
      self.address = address
      self.city = city
      self.state = state
      self.zip = zip
      self.save
    end
  end
  
  # Send Newsletter
  
  def sendNewsletter(timer, deals, featured)
    #sleep timer.to_f
    NotifiMailer.featuredNewsLetter(self, deals, featured).deliver
  end

  # Password area
  
  def self.authenticate(username, password)
    if user = Customer.where(:email => username.downcase).first
      if user.hashed_password == Digest::SHA2.hexdigest(user.salt + password)
        return user
      end
    end
    return nil
  end
  
  def reset_password
    self.reset_key = SecureRandom.base64(12).to_s.gsub(/[^0-9A-Za-z]/, '')
    self.save
    NotifiMailer.reset_password(self).deliver
  end
  
  # Private
  private
  
  def hash_new_password
    self.salt = SecureRandom.base64(8)
    self.hashed_password = Digest::SHA2.hexdigest(self.salt + @new_password)
  end

end
