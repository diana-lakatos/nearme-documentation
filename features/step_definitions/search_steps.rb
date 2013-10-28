When /^I search for "([^"]*)"$/ do |text|
  search_for(text)
end

When /^I search for located "([^"]*)"$/ do |text|
  SearchController.any_instance.stubs(:params).returns({:lat => 1, :lng => 1, :q => text})
  search_for(text)
end

When /^I performed search for "([^"]*)"$/ do |query|
  visit search_path(:q => query)
end

When /^I make another search for "([^"]*)"$/ do |query|
  visit root_path
  search_for(query)
end

When /^I leave the page and hit back$/ do
  visit root_path
  page.evaluate_script('window.history.back()')
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
