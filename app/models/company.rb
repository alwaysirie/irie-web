class Company 
	include MongoMapper::Document
	
	before_create :change_structure
	
	# Password Area
  attr_accessor :new_password, :new_password_confirmation
  validates_confirmation_of :new_password, :if => :password_changed?
  before_save :hash_new_password, :if => :password_changed?
      
  def password_changed?
     !@new_password.blank?
  end

	key :name, String
	key :phone, Phone
	key :url, String
	
	key :active_deals, Integer, :default => 0
	key :pending_deals, Integer, :default => 0
	key :expired_deals, Integer, :default => 0
	
  # Login
  key :username, String
  key :salt, String
  key :hashed_password, String
  key :reset_key, String
  key :new_password2, String
  
	many :store_locations
	many :deals
	
	# Before Functions
	
	def change_structure
	 self.id = "#{Company.all.count.to_i + 1}C"
	 self.url = self.url.gsub('http://', '').gsub('https://', '').to_s
	end
	
	# Actions
	
	def recount_deals
	  self.active_deals = Deal.all(:company_id => self.id, :status => 'active').count
	  self.pending_deals = Deal.all(:company_id => self.id, :status => 'pending').count
	  self.expired_deals = Deal.all(:company_id => self.id, :status.nin => ['active', 'pending']).count
	  self.save
	end
	
	# Helpers
	
	def deal_count
	  (self.active_deals + self.pending_deals + self.expired_deals).to_i
	end
	
	# Password area
  
  def self.authenticate(username, password)
    if user = Company.where(:username => username.downcase).first
      if user.hashed_password == Digest::SHA2.hexdigest(user.salt + password)
        return user.id
      end
    end
    return nil
  end
  
  def reset_password(link)
    self.reset_key = SecureRandom.base64(6).to_s.gsub(/[^0-9A-Za-z]/, '')
    UserMailer.reset_password(self.reset_key, self, link).deliver
    self.save
  end
  
  # Private
  private
  
  def hash_new_password
    self.salt = SecureRandom.base64(8)
    self.hashed_password = Digest::SHA2.hexdigest(self.salt + @new_password)
  end
  
	

end
