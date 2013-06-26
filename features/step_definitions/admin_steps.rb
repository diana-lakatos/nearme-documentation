Given(/^I am in the admin panel$/) do
  visit admin_url
end

When(/^I choose to Login As #{capture_model}$/) do |user|
  user = model!(user)
  visit admin_user_path(user)
  click_link "Login As"
end

