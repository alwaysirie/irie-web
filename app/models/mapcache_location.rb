class MapcacheLocation 
  include MongoMapper::EmbeddedDocument
  
  key :company_name, String
  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :phone, String
  key :lat, String
  key :lng, String
  
  many :mapcache_deals
  
end
