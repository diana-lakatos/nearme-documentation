When /^I add myself as a member of the organization$/ do
  click_link 'Account'
  check model!('organization').name
  click_button "Save Account"
end

Then /^I am a member of the organization$/ do
  model!('user').reload.organizations.should include model!('organization')
end
