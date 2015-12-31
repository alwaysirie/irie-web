class Deal
	include MongoMapper::Document
	before_save :totaldiscount, :update_deal_count
	before_create :change_structure

	key :company_id, ObjectId
	key :company_name, String, :default => ''
	key :name, String

	key :cost, Money
	key :retail, Money
	key :purchases, Integer, :default => 0
	key :gross_profit, Money
	key :discount, Money
	key :max_purchases, Integer, :default => 0
	key :max_per_customer, Integer, :default => 1

	key :start_date, Time
	key :end_date, Time
	
	key :user_exp_date, Time

	key :headline, String
	key :summary, String

	key :description, String
	key :fine_print, String
	
	key :status, Lowercase

  key :locations, Array
  
  #photos
  key :home, String
  key :weekly, String
  key :hero, String
  
	belongs_to :company
	many :vouchers
  
  # Fun Pass
  key :area_name, String
  key :area_id, ObjectId
	
	# Before Filters
  
  def update_deal_count
    Company.find(self.company_id).recount_deals
  end
	
	def change_structure
	  self.id="#{self.company_id}D#{Deal.count(:company_id => self.company_id).to_i + 1}"
	  self.purchases = 0
	  self.company_name = Company.find(self.company_id).name
	end
	
	def totaldiscount
	  self.discount = (self.cost/self.retail)*100.to_i
	  self.gross_profit = self.purchases*self.cost
  end
  
  def timeRemaining
    ((self.end_date - Time.now)/86400).to_i
  end

  # Photos
  
  def upload_photos(photoType, upload)
     name = "#{self.id}_#{photoType}_#{upload["#{photoType}"].original_filename}"
     directory = "public/images/"
     # create the file path
     path = File.join(directory, name)
     # write the file
     File.open(path, "wb") { |f| f.write(upload["#{photoType}"].read) }
     eval("self.#{photoType} = '#{name}'")
     self.save
  end
  
end