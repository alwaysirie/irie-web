class AffiliateDeal
  include MongoMapper::Document
  
  key :customer_id, String
  
  key :percentage, Money
  
  key :deals_sold, Integer
  key :pending_payment, Money
  
  
  belongs_to :customer
  many :affiliate_vouchers
  
  # Actions
  
end
