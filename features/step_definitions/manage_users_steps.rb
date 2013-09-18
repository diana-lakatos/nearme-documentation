When /^I click remove user link$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  click_link "Remove user", :match => :first
end

When /^I fill in user email$/ do
  fill_in 'user_email', with: "#{model!('user').email}" 
end

Then /^I should see info about succesfully added user$/ do
  user = model!('user')
  company = model!('company')
  have_content("You've added #{user.name} to #{company.name}")
end
