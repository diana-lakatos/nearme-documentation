Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  # FUUUUUUUUUUUUUUUUUUUUUUU
  ENV['CURRENT_USER_ID'] = user.id.to_s
end

Then /^I should be logged out$/ do
  Then %{I should see "Login"}
end

