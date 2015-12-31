class Point
  include MongoMapper::Document
  
  
  
  # Actions
  
  def self.addSharePoints(customer_id, points)
    customer = Customer.find(customer_id)
    customer.share_points += points.to_i
  end
  
  def pointsAvailable
    if self.share_points >= 20
      share_points = 20
    else
      share_points = self.share_points.to_i
    end
    return self.purchase_points+share_points
  end
  
  def redeemPoints(points)
    
  end
  
  def cashValue(points)
    return (sprintf "%.2f", (points.to_i*0.25)).to_f
  end
  
end
