Then(/^I should see instances list$/) do
  Instance.all.each do |instance|
    page.should have_content(instance.name)
  end
end

When(/^I fill instance form with valid details$/) do
  fill_in 'instance_name', with: 'Test instance'
  fill_in 'instance_default_search_view', with: 'mixed'
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

And(/^current instance is buyable$/) do
  instance = PlatformContext.current.instance
  instance.update_attribute(:default_search_view, 'products')
end

Given /^a custom attribute (.*) with type (.*) and html_tag (.*) exists$/ do |name, attribute_type, html_tag|
  instance = Instance.unscoped.first
  i = instance.instance_profile_type
  i = InstanceProfileType.create!(instance_id: instance.id) unless i
  User.last.update_attribute(:instance_profile_type_id, i.id)
  messages = NearMeMessageBus.track_publish do
    i.custom_attributes.create!({
      name: name, attribute_type: attribute_type, html_tag: html_tag,
      required: '0', public: '1',
      label: name.gsub('_', ' ').capitalize,
      valid_values: []
    })
  end
  messages.each do |message|
    CacheExpiration.handle_cache_expiration message
  end
end
