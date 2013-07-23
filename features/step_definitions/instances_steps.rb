Then(/^I should see instances list$/) do
  Instance.all.each do |instance|
    page.should have_content(instance.name)
  end
end

When(/^I fill instance form with valid details$/) do
  fill_in 'instance_name', with: 'Test instance'
  fill_in 'instance_domains_attributes_0_name', with: 'dnm.local'
end

Then(/^I should see created instance show page$/) do
  page.should have_content('Instance was successfully created.')
  page.should have_content('Test instance')
  page.should have_content('dnm.local')
end

Then(/^I should see updated instance show page$/) do
  page.should have_content('Instance was successfully updated.')
  page.should have_content('Test instance')
  page.should have_content('dnm.local')
end
