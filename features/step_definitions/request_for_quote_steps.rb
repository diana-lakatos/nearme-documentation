Given /^request for feature is enabled$/ do
  TransactableType::ActionType.update_all(allow_action_rfq: true)
end

When /^I select to request quote( and review)? space for:$/ do |and_review, table|
  bookings = extract_reservation_options(table)
  next if bookings.empty?

  if bookings.first[:start_minute]
    # Hourly bookgs
    ensure_datepicker_open('.date-start')
    select_datepicker_date(bookings.first[:date])

    page.find('.time-picker').click
    page.execute_script <<-JS
      $('.time-start select').val("#{bookings.first[:start_minute]}").trigger('change');
      $('.time-end select').val("#{bookings.first[:end_minute]}").trigger('change');
    JS
  else
    # Daily booking
    start_to_book(bookings.first[:listing], bookings.map { |b| b[:date] }, bookings.first[:quantity])
  end

  step "I click to review the rfq" if and_review

end

When /^I click to review the rfq$/ do
  click_button "Make Offer"
end

Then(/^I should see the request for quote screen for:$/) do |table|
  reservation = extract_reservation_options(table).first
  next unless reservation

  quantity = "#{reservation[:quantity]} x 1 day"
  if reservation[:start_minute]
    hour = (reservation[:start_minute]-reservation[:end_minute])/60.to_f
    quantity = "#{reservation[:quantity]} x #{hour} #{'hour'.pluralize(hour)}"
  end
  assert page.has_content?("#{reservation[:listing].name}")

end

When /^a transactable has action_rfq$/ do
  TransactableType::ActionType.update_all(allow_action_rfq: true)
  Transactable::ActionType.update_all(action_rfq: true)
end
