Given(/^a subscription service is configured$/) do
  @subscription_transactable_type = FactoryGirl.create(:transactable_type_subscription)
  @transactable = FactoryGirl.create(:subscription_transactable)
  @transactable.update_attribute(transactable_type: @subscription_transactable_type)
end

When(/^I subscribe to the service$/) do
  visit location_listing_path(@transactable.location, @transactable)
  click_button "Book"
  fill_in 'reservation_request_checkout_extra_fields_user_properties_license_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_mobile_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '12312341'
  fill_in 'reservation_request_checkout_extra_fields_user_company_name', with: '12312341'
end

Then(/^I am subscribed to the service$/) do
end
