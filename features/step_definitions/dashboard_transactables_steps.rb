Given(/^I am browsing transactables$/) do
  visit dashboard_transactable_type_transactables_path(TransactableType.first)
end

Given(/^I am adding new transactable$/) do
  visit new_dashboard_transactable_type_transactable_path(TransactableType.first)
end

Given(/^I add a new transactable$/) do
  find(:css, '.new-profile a').click
end

Given(/^I add a new location$/) do
  find(:css, '.add-new a').click
end

Given(/^I edit first location$/) do
  find(:css, '#location-list .location-options > a:first-child').click
end

Given(/^I remove first location$/) do
  find(:css, '#location-list .location-options > a:last-child').click
end

Given(/^I edit first transactable$/) do
  find(:css, '.listings div:last-child > a:first-child').click
end

Given(/^I remove first transactable$/) do
  find(:css, '.listings div:last-child > a:last-child').click
end

