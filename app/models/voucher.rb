require 'digest/sha2'
class Voucher
	include MongoMapper::Document
	before_create :change_id
  after_create :update_customer
	
	def change_id
	 self.id = "#{self.deal.company_id.upcase}V#{Time.now.strftime('%s')}#{SecureRandom.base64(4).to_s.gsub(/[^0-9A-Za-z]/, '').upcase}"
	 customer = Customer.find(self.customer_id)
	 if customer != nil
	   self.customer_first_name = customer.first_name
	   self.customer_last_name = customer.last_name
   end
   self.company_id = self.deal.company_id
	end
  
  def update_customer
    Customer.find(self.customer_id).update_stats
  end

	key :customer_id, ObjectId
	key :customer_first_name, Lowercase
	key :customer_last_name, Lowercase
	key :deal_id, ObjectId
	
	#deal Info
	key :company_name, String
	key :company_id, ObjectId
	key :headline, String
	key :cost, Money
	key :retail, Money
	key :description, String
	key :fine_print, String

	key :start_date, Time
	key :exp_date, Time
	key :purchase_date, Time

	key :status, String

	key :used_date, String
	
	# Card Info
	key :transaction_id, String
	key :authorization_code, String
	
	# Earning Stats
	key :affiliate_cost, Money, :default => 0
	key :earnings, Money, :default => 0
	
	belongs_to :customer
	belongs_to :deal
	many :voucher_payments
  
  def savings
    return self.retail-self.cost
  end

	# Actions
	
	def self.createVoucher(deal_id, customer_id)
	 existing = Voucher.first(:customer_id => customer_id, :deal_id => deal_id, :status => 'pending')
	 if existing != nil
	   return existing
   end
   deal = Deal.find(deal_id)
   if deal.max_per_customer.to_i <= 1
     purchased = Voucher.first(:customer_id => customer_id, :deal_id => deal_id, :status.ne => 'pending')
 	   if purchased != nil
 	     return 'purchased'
     end
   end
	 voucher = Voucher.new()
	 voucher.deal_id = deal_id
	 voucher.customer_id = customer_id
	 voucher.start_date = Time.now
	 voucher.exp_date = deal.user_exp_date
	 voucher.cost = deal.cost
	 voucher.retail = deal.retail
	 voucher.status = 'pending'
	 voucher.company_name = deal.company_name
	 voucher.save
	 return voucher
	end
	
	# multiple
	
	def self.createVouchers(deal_id, customer_id, qty)
	  deal = Deal.find(deal_id)
	  purchased = Voucher.all(:customer_id => customer_id, :deal_id => deal_id, :status.ne => 'pending').count
	  if deal.max_per_customer.to_i < purchased+qty.to_i
	    return 'purchased'
    end
	  existing = Voucher.where(:customer_id => customer_id, :deal_id => deal_id, :status => 'pending').limit(qty.to_i)
	  remaining_qty = qty.to_i - existing.count
	  if remaining_qty >= 1
	    remaining_qty.to_i.times do
	       voucher = Voucher.new()
      	 voucher.deal_id = deal_id
      	 voucher.customer_id = customer_id
      	 voucher.start_date = Time.now
      	 voucher.exp_date = deal.user_exp_date
      	 voucher.cost = deal.cost
      	 voucher.retail = deal.retail
      	 voucher.status = 'pending'
      	 voucher.company_name = deal.company_name
      	 voucher.save
      end
    end
    vouchers = Voucher.where(:customer_id => customer_id, :deal_id => deal_id, :status => 'pending').limit(qty.to_i)
    return vouchers
	end
	
	def markPurchased(affiliate_id)
	  self.status = 'active'
	  self.purchase_date = Time.now
	  self.save
	  if affiliate_id != nil || affiliate_id != ''
	    Customer.find(self.customer_id).addAffiliateDeal(affiliate_id, self.id)
    end
    deal = Deal.find(self.deal_id)
    deal.purchases += 1
    deal.save
    customer = Customer.find(self.customer_id)
    customer.deals_purchased+=1
    customer.money_saved+=(deal.retail.to_f-deal.cost.to_f)
    customer.points+=deal.cost.to_i
    customer.save
	  NotifiMailer.receipt(Customer.find(self.customer_id), self, Deal.find(self.deal_id)).deliver
  end
  
  

end
