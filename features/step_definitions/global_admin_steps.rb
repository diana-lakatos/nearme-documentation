Given(/^I am in the admin panel$/) do
  visit global_admin_url
end

When(/^I choose to Login As #{capture_model}$/) do |user|
  user = model!(user)
  visit global_admin_user_path(user)
  click_link "Login As"
end

Then(/^I should be in the admin panel$/) do
  assert page.has_content?('Desks Near Me Admin')
end

