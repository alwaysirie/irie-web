class Location
	include MongoMapper::EmbeddedDocument

	key :address, String
	key :city, String
	key :state, String
	key :zip, String
  
end
