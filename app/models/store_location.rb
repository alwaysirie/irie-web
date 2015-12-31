#include GeoKit::Geocoders
class StoreLocation
  include MongoMapper::EmbeddedDocument
  #include Geocoder::Model::MongoMapper
  #geocoded_by :address, :skip_index => true, :latitude  => :lat, :longitude => :lng
  #before_save :geocode
  before_save :geofy
  
  key :name, String, :default => ''
  key :address, String, :default => ''
  key :city, String, :default => ''
  key :state, String, :default => ''
  key :zip, String, :default => ''
  key :phone, String, :default => ''
  key :lat, String, :default => ''
  key :lng, String, :default => ''
  key :coordinates, Array
  
  many :operation_hours
  
  # hours of Operation
  key :sunday_open, String, :default => ''
  key :sunday_open_ampm, String, :default => ''
  key :sunday_close, String, :default => ''
  key :sunday_close_ampm, String, :default => ''
  
  key :monday_open, String, :default => ''
  key :monday_open_ampm, String, :default => ''
  key :monday_close, String, :default => ''
  key :monday_close_ampm, String, :default => ''
  
  key :tuesday_open, String, :default => ''
  key :tuesday_open_ampm, String, :default => ''
  key :tuesday_close, String, :default => ''
  key :tuesday_close_ampm, String, :default => ''
  
  key :wednesday_open, String, :default => ''
  key :wednesday_open_ampm, String, :default => ''
  key :wednesday_close, String, :default => ''
  key :wednesday_close_ampm, String, :default => ''
  
  key :thursday_open, String, :default => ''
  key :thursday_open_ampm, String, :default => ''
  key :thursday_close, String, :default => ''
  key :thursday_close_ampm, String, :default => ''
  
  key :friday_open, String, :default => ''
  key :friday_open_ampm, String, :default => ''
  key :friday_close, String, :default => ''
  key :friday_close_ampm, String, :default => ''
  
  key :saturday_open, String, :default => ''
  key :saturday_open_ampm, String, :default => ''
  key :saturday_close, String, :default => ''
  key :saturday_close_ampm, String, :default => ''
  
  # Helper
  
  def full_address
    "#{self.address}<br>#{self.city}, #{self.state} #{self.zip}"
  end
  
  def googleaddress
    ("#{self.address},#{self.city}, #{self.state} #{self.zip}").gsub(' ', '+')
  end
  
  def geofy
    #require 'geokit'
    #coords = MultiGeocoder.geocode("#{self.address}, #{self.city}, #{self.state} #{self.zip}")
    #self.lat = coords.lat
    #self.lng = coords.lng
    
    #res=Geokit::Geocoders::MultiGeocoder.geocode("'#{self.address}, #{self.city}, #{self.state}'")
    #puts res.ll # ll=latitude,longitude
    if !self.address.blank? && !self.zip.blank?
      coords = Geocoder.search("#{self.address}, #{self.city}, #{self.state} #{self.zip}")[0]
      self.lat = coords.latitude
      self.lng = coords.longitude
    end
  end
  
end
