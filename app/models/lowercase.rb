class Lowercase < String
  def self.to_mongo(value)
     if value != nil && value != ''
       value.downcase
     end
   end

   def self.from_mongo(value)
     value
   end
end