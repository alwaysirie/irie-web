class NotifiMailer < ActionMailer::Base
  default from: "hello@nytlife.com"
  
  def sendLead(lead)
    @lead = lead
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    mail(:to => "Steffan Perry <sperry@nytlife.com>, Chris Gutierrez <chris@nytlife.com>, Danny Yaldor <danny@nytlife.com>", :subject => "NytLife Solutions Lead", :from => "NytLife <hello@nytlife.com>")
  end
  
  def register(user)
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    @user = user
    mail(:to => "#{user.first_name.titleize} #{user.last_name.titleize} <#{user.email}>", :subject => "Welcome To NytLife", :from => "NytLife <hello@nytlife.com>")
  end
  
  def preregister(user)
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    @user = user
    mail(:to => "#{user.first_name.titleize} #{user.last_name.titleize} <#{user.email}>", :subject => "Welcome To NytLife", :from => "NytLife <hello@nytlife.com>")
  end
  
  def launch(user)
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    @user = user
    mail(:to => "#{user.first_name.titleize} #{user.last_name.titleize} <#{user.email}>", :subject => "Welcome To NytLife : Erick Morillo LIVE!", :from => "NytLife <hello@nytlife.com>")
  end
  
  def reset_password(user)
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    @user = user
    mail(:to => "#{user.first_name.titleize} #{user.last_name.titleize} <#{user.email}>", :subject => "Password Reset", :from => "NytLife <hello@nytlife.com>")
  end
  
  def receipt(user, voucher, deal)
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    @user = user
    @voucher = voucher
    @deal = deal
    mail(:to => "#{user.first_name.titleize} #{user.last_name.titleize} <#{user.email}>", :subject => "RECEIPT: #{deal.headline}", :from => "NytLife <hello@nytlife.com>")
  end
  
  def featuredNewsLetter(user, deals, featured)
    headers['Errors-To'] = "hello@nytlife.com"
    headers['Return-Path'] = "hello@nytlife.com"
    @user = user
    @featured = featured
    @deals = deals
    mail(:to => "#{user.first_name.titleize} #{user.last_name.titleize} <#{user.email}>", :subject => "Plan Your Nyt :: #{featured.headline} @ #{featured.company_name}", :from => "NytLife <hello@nytlife.com>")
  end
  
end
