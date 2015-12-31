class AdminController < ApplicationController
  
  def createAdmin
    admin = Admin.new()
    admin.email = 'Kristen@tampabayfunpass.com'
    admin.new_password = 'FunPass123'
    admin.first_name = 'Kristen'
    admin.last_name = 'Yaldor'
    admin.save
    redirect_to("/")
  end

end