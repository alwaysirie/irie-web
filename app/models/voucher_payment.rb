class VoucherPayment
  include MongoMapper::Document
  
  key :voucher_id, ObjectId
  key :payment_type, Integer # 1 = credit_card, 2 = PayPal
  key :amount, Money
  key :status, Integer # 1 = Paid, 2 = Refunded
  key :transaction_id, String
  key :authorization_code, String
  key :created_at, Time
  
  belongs_to :voucher
  
  def self.processPayment(payment_type, amount, card_id, voucher_id)
    voucher = Voucher.find(voucher_id)
    voucherPayment = VoucherPayment.new(:voucher_id => voucher_id, :payment_type => payment_type, :amount => amount,  :created_at => Time.now)
    if payment_type == 1
      response = chargeCreditCard(card_id, voucher.customer.first_name, voucher.customer.last_name, amount)
    end
    if payment_type == 2
      
    end
    if response['status'] == 'success'
      voucherPayment.transaction_id = response['transaction_id']
      voucherPayment.transaction_id = response['authorization_code']
      voucherPayment.status = 1
      voucherPayment.save
      return true
    else
      return false
    end
  end
  
  def self.processPaymentNew(payment_type, amount, card_id, vouchers)
    if payment_type == 1
      response = chargeCreditCard(card_id, vouchers.first.customer.first_name, vouchers.first.customer.last_name, amount)
    end
    if response['status'] == 'success'
      for v in vouchers
        voucherPayment = VoucherPayment.new(:voucher_id => v.id, :payment_type => payment_type, :amount => (amount.to_f/vouchers.count),  :created_at => Time.now)
        voucherPayment.transaction_id = response['transaction_id']
        voucherPayment.transaction_id = response['authorization_code']
        voucherPayment.status = 1
        voucherPayment.save
      end
      return true
    else
      return false
    end
  end
  
  private # Private Section
  
  def self.chargeCreditCard(card_id, user_first_name, user_last_name, amount)
    card = CreditCard.find(card_id)
    #transaction = AuthorizeNet::AIM::Transaction.new('7w5Z4S9rg4T', '5XTd742mEvvN739D', :gateway => :live)
    # testing
    transaction = AuthorizeNet::AIM::Transaction.new('9vh9n68KHMFn', '788sH2d4X6sa3GN9', :gateway => :sandbox)
    #end testing
    address = AuthorizeNet::Address.new(:first_name => user_first_name, :last_name => user_last_name, :street_address => card.address, :city => card.city, :state => card.state, :zip => card.zip)
    transaction.set_address(address)
    credit_card = AuthorizeNet::CreditCard.new("#{card.number}", "#{card.exp_month}#{card.exp_year}")
    response = transaction.purchase("#{amount}", credit_card)
    if response.success?
      return {'status' => 'success', 'transaction_id' => response.transaction_id, 'authorization_code' => response.authorization_code}
    else
      return {'status' => 'fail'}
    end
  end
  
  
  
  
  
end
