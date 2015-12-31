class MapcacheDeal
  include MongoMapper::EmbeddedDocument
  
  key :headline, String
  key :cost, String
  key :retail, String
  
end
