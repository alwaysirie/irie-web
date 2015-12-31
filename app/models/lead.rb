class Lead
  include MongoMapper::Document
  
  after_create :sendLead
  
  key :first_name, String
  key :last_name, String
  key :company_name, String
  key :email, Lowercase
  key :phone, Phone
  
  def sendLead
    NotifiMailer.sendLead(self).deliver
  end
  
end
