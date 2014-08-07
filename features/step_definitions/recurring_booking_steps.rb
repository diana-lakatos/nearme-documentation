Given /recurre booking is enabled/ do
  TransactableType.first.update_attribute(:recurring_booking, true)
end

When /^I select to recurre book( and review)? space for:$/ do |and_review, table|
  bookings = extract_recurring_booking_options(table)
  next if bookings.empty?

  if bookings.first[:start_minute]
    # Hourly bookgs
    ensure_datepicker_open('.date-start')
    select_datepicker_date(bookings.first[:start_on])

    page.find('.time-picker').click
    page.execute_script <<-JS
      $('.time-start select').val("#{bookings.first[:start_minute]}").trigger('change');
      $('.time-end select').val("#{bookings.first[:end_minute]}").trigger('change');
    JS
  else
    # Daily booking
    start_to_book(bookings.first[:listing], bookings.map { |b| [b[:start_on], b[:end_on]] }.flatten, bookings.first[:quantity])
  end
end

When /^I recurre book space for:$/ do |table|
  step "I select to recurre book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  step "I click to confirm the booking"
end

