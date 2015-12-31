class Area
  include MongoMapper::Document
  scope :active, where(:hide.ne => 1)
  
  # General 
  key :name, String
  key :hide, Integer, :default => 0
  
  
end
