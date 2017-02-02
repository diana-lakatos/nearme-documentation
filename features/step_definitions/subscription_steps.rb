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
  fill_in 'order_payment_subscription_attributes_credit_card_attributes_first_name', with: 'FirstName'
  fill_in 'order_payment_subscription_attributes_credit_card_attributes_last_name', with: 'LastName'
  # note we provide invalid credit card number on purpose - payment.js should validate the input and remove unnecessary 555
  page.execute_script("$('#order_payment_subscription_attributes_credit_card_attributes_number').val('42 42424 24242 4242 555').trigger('change')")
  select '12', from: 'order_payment_subscription_attributes_credit_card_attributes_month', visible: false
  select '2020', from: 'order_payment_subscription_attributes_credit_card_attributes_year', visible: false
  fill_in 'order_payment_subscription_attributes_credit_card_attributes_verification_value', :with => '411'
  @credit_card_reservation = true
end
