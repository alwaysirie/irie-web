ActionMailer::Base.smtp_settings = {
  :address              => "email-smtp.us-east-1.amazonaws.com",
  :port                 => 587,
  :domain               => "nytlife.com",
  :user_name            => "AKIAI2QBLAZIUJKYCKSQ",
  :password             => "AoLVzKQQkg6StTeqj1lC96Lvh3KT4yG1OcP+e8N73wZf",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "nytlife.com"