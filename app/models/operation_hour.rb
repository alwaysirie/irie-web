class OperationHour
  include MongoMapper::EmbeddedDocument
  
  key :day, String
  key :open, String
  key :close, String
end
