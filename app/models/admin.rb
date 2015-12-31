require 'digest/sha2'
class Admin
	include MongoMapper::Document
  
	# Password Area
  attr_accessor :new_password, :new_password_confirmation
  validates_confirmation_of :new_password, :if => :password_changed?
  before_save :hash_new_password, :if => :password_changed?
      
  def password_changed?
     !@new_password.blank?
  end

  key :first_name, Lowercase, :default => ''
  key :last_name, Lowercase, :default => ''
  key :email, Lowercase, :unique => true
	
	# Login
  key :salt, String
  key :hashed_password, String
  key :reset_key, String
  key :new_password2, String
  
  # Password area
  
  def self.authenticate(username, password)
    if user = Admin.where(:email => username.downcase).first
      if user.hashed_password == Digest::SHA2.hexdigest(user.salt + password)
        return user
      end
    end
    return nil
  end
  
  def reset_password
    self.reset_key = SecureRandom.base64(12).to_s.gsub(/[^0-9A-Za-z]/, '')
    self.save
    NotifiMailer.reset_password(self).deliver
  end
  
  # Private
  private
  
  def hash_new_password
    self.salt = SecureRandom.base64(8)
    self.hashed_password = Digest::SHA2.hexdigest(self.salt + @new_password)
  end

	

end
