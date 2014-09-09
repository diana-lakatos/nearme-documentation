Given /recurre booking is enabled/ do
  TransactableType.first.update_attribute(:recurring_booking, true)
end

When /^I select to recurre book( and review)? space for:$/ do |and_review, table|
  bookings = extract_recurring_booking_options(table)
  next if bookings.empty?

  ensure_datepicker_open('.date-start')
  select_datepicker_date(bookings.first[:start_on])
  ensure_datepicker_open('.date-end')
  select_datepicker_date(bookings.first[:end_on])
  select bookings.first[:quantity].to_s, :from => "quantity"
  recurring_booking_rule = '{"validations":{"day":[1]},"rule_type":"IceCube::WeeklyRule","interval":1,"week_start":0}'
  page.execute_script "$('select#reservation_request_schedule_params').find('option').eq(0).val('#{recurring_booking_rule}').parent('select').trigger('change')"
  if bookings.first[:start_minute]
    # Hourly bookgs

    page.find('.time-picker').click
    page.execute_script <<-JS
      $('.time-start select').val("#{bookings.first[:start_minute]}").trigger('change');
      $('.time-end select').val("#{bookings.first[:end_minute]}").trigger('change');
    JS
  end
  step "I click to review the booking" if and_review
end

When /^I recurre book space for:$/ do |table|
  step "I select to recurre book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  step "I click to confirm the booking"
end

When /^I recurre book space as new user for:$/ do |table|
  step "I select to recurre book space for:", table
  step "I click to review the booking"
  step 'I sign up as a user in the modal'
  store_model("user", "user", User.last)
  #select "New Zealand", :from => 'reservation_request_country_name'
  page.execute_script "$('select#reservation_request_country_name option[value=\"New Zealand\"]').prop('selected', true).trigger('change');"
  fill_in 'Mobile number', with: '8889983375'
  step "I provide reservation credit card details"
  step "I click to confirm the booking"
end

Then /^I should be redirected to recurring bookings page$/ do
  page.should have_content('Your reservation has been made!')
  assert_includes URI.parse(current_url).path, recurring_booking_successful_reservation_path(RecurringBooking.last)
end

Then /^I should see the recurring booking confirmation screen for:$/ do |table|
  recurring_booking = extract_recurring_booking_options(table).first
  next unless recurring_booking

  if recurring_booking[:start_minute]
    # Hourly booking
    start_on = recurring_booking[:start_on].strftime("%-e %b %Y")
    end_on = recurring_booking[:end_on].strftime("%-e %b %Y")
    start_time = recurring_booking[:start_at].strftime("%l:%M%P")
    end_time   = recurring_booking[:end_at].strftime("%l:%M%P").strip
    assert page.has_content?(start_on), "Expected to see start on: #{start_on}"
    assert page.has_content?(end_on), "Expected to see end on: #{end_on}"
    assert page.has_content?(start_time), "Expected to see: #{start_time}"
    assert page.has_content?(end_time), "Expected to see: #{end_time}"
  else
    # Daily booking
    assert page.has_content?("#{recurring_booking[:listing].name}")
  end

end

When /^#{capture_model} should have(?: ([0-9]+) of)? #{capture_model} recurred reserved for '(.+)' and '(.+)'$/ do |user, qty, listing, start_on, end_on|
  user = model!(user)
  qty = qty ? qty.to_i : 1

  listing = model!(listing)

  date = Chronic.parse(date).to_date
  assert listing.recurring_bookings.any? { |recurring_booking|
    recurring_booking.owner == user && recurring_booking.quantity == qty && recurring_booking.start_on == start_on && recurring_booking.end_on = end_on
  }, "Unable to find a recurring booking for #{listing.name} on #{start_on}-#{end_on} with quantity #{qty} - #{RecurringBooking.last.inspect}"
end

Then /^#{capture_model} should have a recurring booking:$/ do |user, table|
  user = model!(user)
  recurring_booking = extract_recurring_booking_options(table).first
  created_recurring_booking = user.recurring_bookings.last

  assert_equal recurring_booking[:listing], created_recurring_booking.listing
  assert_equal recurring_booking[:quantity], created_recurring_booking.quantity
  assert_equal recurring_booking[:start_on], created_recurring_booking.start_on
  assert_equal recurring_booking[:end_on], created_recurring_booking.end_on
  assert_equal recurring_booking[:start_minute], created_recurring_booking.start_minute if recurring_booking[:start_minute]
  assert_equal recurring_booking[:end_minute], created_recurring_booking.end_minute if recurring_booking[:end_minute]
end

