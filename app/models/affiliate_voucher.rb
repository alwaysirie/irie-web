class AffiliateVoucher
  include MongoMapper::EmbeddedDocument
  
  key :voucher_id, ObjectId
  key :customer_id, ObjectId
  key :amount, Money
  key :earned, Money
  
end
