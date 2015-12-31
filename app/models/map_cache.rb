class MapCache
  include MongoMapper::Document
  
  key :date, String
  many :mapcache_locations
  
  
  def self.getCache
    cache = nil #MapCache.first(:date => Time.now.utc.to_date.to_s)
    if cache == nil
      cache = updateCache
    end
    return cache
  end
  
  def self.updateCache
    cache = MapCache.new(:date => Time.now.utc.to_date.to_s)
    
    deals = Deal.where(:$or =>[{:status => 'featured'}, {:status => 'active'}])
    companies = Company.all()
    for c in companies
      for l in c.store_locations
        location = MapcacheLocation.new(:id => l.id, :company_name => c.name, :address => l.address, :city => l.city, :state => l.state, :zip => l.zip, :phone => l.phone, :lat => l.lat, :lng => l.lng)
        for d in deals
          if d.locations.include?(l.id.to_s)
            location.mapcache_deals << MapcacheDeal.new(:id => d.id, :headline => d.headline, :cost => d.cost, :retail => d.retail)
          end
        end
        if location.mapcache_deals.count >= 1
          cache.mapcache_locations << location
        end
      end
    end
    cache.save
    return cache
  end
  
end