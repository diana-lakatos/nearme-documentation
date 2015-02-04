Given(/^I am browsing transactables$/) do
  visit dashboard_transactable_type_transactables_path(TransactableType.first)
end

Given(/^I am browsing bulk upload transactables$/) do
  visit dashboard_transactable_type_transactables_path(TransactableType.last)
end

Given(/^I am adding new transactable$/) do
  visit new_dashboard_transactable_type_transactable_path(TransactableType.last)
end

Given(/^I add a new transactable$/) do
  find(:css, 'a.new-transactable-btn ').click
end

Given(/^I add a new location$/) do
  find(:css, '.add-new a').click
end

Given(/^I edit first location$/) do
  all(:css, '#location-list .location-options > a:first-child').first.click
  page.should have_css('#location-form')
end

Given(/^I remove all locations$/) do
  all(:css, '#location-list .location-options > a:last-child').each do |remove_location|
    remove_location.click
  end
end

Given(/^I edit first transactable$/) do
  all(:css, '.listings div:last-child > a:first-child').last.click
end

Given(/^I remove first transactable$/) do
  first(:css, '.listings div:last-child > a:last-child').click
end

