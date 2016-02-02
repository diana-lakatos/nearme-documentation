When(/^I subscribe to the service$/) do
  step "I click to review the booking"
  step("I provide recurring reservation credit card details")
  step "I click to confirm the booking"
end

Then(/^I am subscribed to the service$/) do
  user = model!("the user")
  recurring_booking = user.recurring_bookings.last
  assert_equal model!("the location"), recurring_booking.location
end

Then(/^I should see all text:$/) do |table|
  table.rows.flatten.each do |text|
    should have_content(text)
  end
end

When(/^I (confirm|cancel) the subscription$/) do |button_text|
  click_button(button_text.capitalize)
end

When /^I provide recurring reservation credit card details$/ do
  mock_billing_gateway
  fill_in 'reservation_request_card_holder_first_name', with: 'FirstName'
  fill_in 'reservation_request_card_holder_last_name', with: 'LastName'
  fill_in 'reservation_request_card_number', :with => "4242424242424242"
  select '12', from: 'reservation_request_card_exp_month', visible: false
  select '2020', from: 'reservation_request_card_exp_year', visible: false
  fill_in 'reservation_request_card_code', :with => '411'
  @credit_card_reservation = true
end
