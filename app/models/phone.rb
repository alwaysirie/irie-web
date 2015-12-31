class Phone < Integer
   def self.to_mongo(value)
     if value != nil && value != ''
       value.to_s.gsub(/\D/, "").to_i
     end
   end

   def self.from_mongo(value)
     value
   end
end
