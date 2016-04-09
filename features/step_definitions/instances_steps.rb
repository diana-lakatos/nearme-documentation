Then(/^I should see instances list$/) do
  Instance.all.each do |instance|
    page.should have_content(instance.name)
  end
end

When(/^I fill instance form with valid details$/) do
  fill_in 'instance_name', with: 'Test instance'
end

When(/^I fill instance form with a valid user$/) do
  fill_in 'user_name', with: 'Joe Smith'
  fill_in 'user_email', with: 'Joe@example.com'
end

When(/^I browse instance$/) do
  all(:css, '.table tr a').first.click
end

When(/^I edit instance$/) do
  all(:css, '.table tr .btn', text: 'Edit').first.click
end

Then(/^I should see updated instance show page$/) do
  page.should have_content('Instance was successfully updated.')
  page.should have_content('mixed')
end

Then(/^I should have blog instance created$/) do
  BlogInstance.last.name.should == 'Test instance Blog'
end

When /^new ui is turned on$/ do
  PlatformContext.current.instance.update! priority_view_path: 'new_ui'
end
