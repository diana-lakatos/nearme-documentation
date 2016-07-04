Given(/^instance has default availability templates$/) do
  PlatformContext.current.instance.tap { |i| i.build_availability_templates }.save!
end

Given(/^I am browsing transactables$/) do
  visit dashboard_company_transactable_type_transactables_path(TransactableType.first)
end

Given(/^I am browsing bulk upload transactables$/) do
  visit dashboard_company_transactable_type_transactables_path(TransactableType.last)
end

Given(/^I am adding new transactable$/) do
  visit new_dashboard_company_transactable_type_transactable_path(TransactableType.last)
end

Given(/^I add a new transactable$/) do
  find(:css, '.additional-listing-options a:last-child').click
end

Given(/^I add a new location$/) do
  within('[data-location-actions]') do
    click_link 'Add New Location'
  end
end

Given(/^I edit first location$/) do
  within('[data-location-actions]') do
    click_link 'Edit'
  end
end

Given(/^I remove all locations$/) do
  within('[data-location-actions]') do
    click_link 'Remove'
  end
end

Given(/^I edit first transactable$/) do
  all(:css, '.table-listing tr:last-child td:last-child a').last.click
end

Given(/^I remove first transactable$/) do
  all(:css, '.table-listing tr:last-child td:last-child a').last.click
  click_link 'Delete'
end

Given(/^transactable type has multiple booking types enabled$/) do
  TransactableType.first.time_based_booking.pricings << FactoryGirl.create(:transactable_type_pricing, unit: 'night')
  TransactableType.first.time_based_booking.pricings << FactoryGirl.create(:transactable_type_pricing, number_of_units: 5)
end

Given(/^I click on overnight booking tab$/) do
  click_link 'Pricing & Availability'
  page.execute_script("$('#transactable_action_types_attributes_0_pricings_attributes_2_enabled').prop('checked', true)")
  page.execute_script("$('#transactable_action_types_attributes_0_pricings_attributes_2_enabled').trigger('change')")
  fill_in "transactable_action_types_attributes_0_pricings_attributes_2_price", with: "10"
  click_link 'Details'
end

Then(/^transactables booking type is overnight$/) do
  Transactable.last.action_type.night_booking? == true
end
