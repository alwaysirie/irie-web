class CreditCard
  include MongoMapper::Document
  
  # Card Details
  key :number, Phone
  key :exp_month, String
  key :exp_year, String
  key :cvv, String
  key :name, String
  
  # Billing Address
  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  
  # customer
  key :customer_id, ObjectId
  
  belongs_to :customer
  
  def self.create_card(card_info, customer_id)
    if card_info['number'] == '' || card_info['month'] == '' || card_info['year'] == nil
      return nil
    end
    existing_card = CreditCard.first(:number => card_info['number'].gsub(/\D/, "").to_i, :customer_id => customer_id)
    if existing_card != nil
      existing_card.update_attributes(:exp_month => card_info['month'],:exp_year => card_info['year'],:cvv => card_info['cvv'],:name => card_info['name'],:address => card_info['address'],:city => card_info['city'],:state => card_info['state'],:zip => card_info['zip'])
      return existing_card
    end
    card = CreditCard.new
    card.number = card_info['number']
    card.exp_month = card_info['month']
    card.exp_year = card_info['year']
    card.cvv = card_info['cvv']
    card.name = card_info['name']
    card.address = card_info['address']
    card.city = card_info['city']
    card.state = card_info['state']
    card.zip = card_info['zip']
    card.customer_id = customer_id
    card.save
    return card
  end
  

  
  # 
  
  def last_four
    "#{self.number.to_s.slice(-4..-1)}"
  end
  
  def exp_date
    "#{self.exp_month}/#{self.exp_year}"
  end
  
  
  
end
