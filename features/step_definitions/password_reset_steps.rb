When /^I follow the password reset link for #{capture_model}$/ do |user_instance|
  user = model!(user_instance)
  visit edit_user_password_path(:reset_password_token => user.reset_password_token)
end
