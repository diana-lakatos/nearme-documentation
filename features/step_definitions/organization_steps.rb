Given /^I am a member of (?:the above|that) organization$/ do
  user = @user || model!('user')
  user.organizations << model!('organization')
  user.reload.organizations.should include model!('organization')
end

When /^I add myself as a member of the organization$/ do
  click_link 'Account'
  check model!('organization').name
  click_button "Save Changes"
end

Then /^I am a member of the organization$/ do
  model!('user').reload.organizations.should include model!('organization')
end
