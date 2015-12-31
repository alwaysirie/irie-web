class Money < Float
   def self.to_mongo(value)
     if value != nil && value != ''
       (sprintf "%.2f", value).to_f
     else
       (sprintf "%.2f", 0.00).to_f
     end
   end

   def self.from_mongo(value)
     if value != nil
        (sprintf "%.2f", value).to_f
      else
        (sprintf "%.2f", 0.00).to_f
      end
   end
end
