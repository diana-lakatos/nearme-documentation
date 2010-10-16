Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  cookies[:remember_token] = user.remember_token
end
