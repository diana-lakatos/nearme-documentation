When /^I search for "([^"]*)"$/ do |text|
  search_for(text)
end

When /^I search for located "([^"]*)"$/ do |text|
  SearchController.any_instance.stubs(:params).returns({:lat => 1, :lng => 1, :q => text})
  search_for(text)
end

When /^I search without setting a date range$/ do
  visit search_path
  search_for(latest_listing.address)
  wait_until_results_are_returned
end

When /^I performed search for "([^"]*)"$/ do |query|
  visit search_path(:q => query)
end

When /^I make another search for "([^"]*)"$/ do |query|
  visit root_path
  search_for(query)
end

When /^I search with a date range of 2 weeks$/ do
  visit search_path
  search_for(listing.address, { start_date: Time.zone.today, end_date: 2.weeks.from_now })
end

When /^I leave the page and hit back$/ do
  visit root_path
  page.evaluate_script('window.history.back()')
end

When /^I view the results in the (map|list) view$/ do |view|
  click_link view.titlecase
end

Then /^all the listings are included in the search results$/ do
  Listing.all.each do |listing|
    page.should have_content listing.name
  end
end

Then /^I see the listings on a map$/ do
  page.should have_css('#listings_map')
end

Then /^that listing is( not)? included in the search results$/ do |not_included|
  if not_included
    page.should_not have_content listing.name
  else
    page.should have_content listing.name
  end
end

When(/^I fill form (with email field )?for subscribing on notification$/) do |with_email|
  page.should have_css('#search-notification')
  if with_email
    fill_in 'search_notification_email', with: 'test@test.com'
  end
  click_on 'Subscribe'
end

Then /^I should see a notification for my subscription$/ do
  page.find('.alert').should have_content("You will be notified when a desk is added at this location.")
end

When(/^search notification created with "([^"]*)"( for user)?$/) do |query, for_user|
  last_notification = SearchNotification.last
  last_notification.query.should == query
  if for_user
    last_notification.user.should == model!('the user')
  else
    last_notification.email.should == 'test@test.com'
  end
end

Given /^both listings in Auckland belongs to different desk type$/ do
  @first_listing.update_attribute(:listing_type_id, FactoryGirl.create(:listing_type, :name => 'first listing type').id)
  @first_filter = @first_listing.listing_type
  @second_listing.update_attribute(:listing_type_id, FactoryGirl.create(:listing_type, :name => 'second listing type').id)
end

Given /^both listings in Auckland belongs to different location type$/ do
  @first_listing.location.update_attribute(:location_type_id, FactoryGirl.create(:location_type, :name => 'first location type').id)
  @first_filter = @first_listing.location.location_type
  @second_listing.location.update_attribute(:location_type_id, FactoryGirl.create(:location_type, :name => 'second location type').id)
end

Given /^both listings in Auckland belongs to different industry$/ do
  company = @first_listing.location.company 
  company.industries = [FactoryGirl.create(:industry, :name => 'first industry')]
  company.save!
  @first_filter = @first_listing.location.company.industries.first
  company = @second_listing.location.company 
  company.industries = [FactoryGirl.create(:industry, :name => 'second industry')]
  company.save!
end

When /^I filter by (.*)$/ do |filter_parameter|
  parsed_filter = filter_parameter.underscore.tr(" ","_")
  page.find(:css, ".#{parsed_filter}").click
  parsed_filter = 'listing_types' if parsed_filter == 'desk_types'
  page.first(:css, 'input[name="' + parsed_filter + '_ids[]"][value="' + "#{@first_filter.id}" + '"]').set(true)
end

Then /^I see a search result that satisfies filter$/ do
    page.should have_selector('article[data-name="' + @first_listing.name + '"]')
    page.should have_no_selector('article[data-name="' + @second_listing.name + '"]')
end
