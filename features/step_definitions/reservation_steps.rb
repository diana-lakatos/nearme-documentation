Given /^(.*) has a( |n un)confirmed reservation for (.*)$/ do |lister, confirmed, reserver|
  lister = User.find_by_name(lister)
  reserver = User.find_by_name(reserver)
  @listing = FactoryGirl.create(:transactable)
  @listing.company.update_attribute(:creator_id, lister.id)
  @listing.company.add_creator_to_company_users
  @listing.reload
  reservation = @listing.reserve!(reserver, [next_regularly_available_day], 1)
  unless confirmed != " "
    reservation.confirm!
    reservation.save!
  end

end

Given /^Reservation alerts exist$/ do
  Utils::DefaultAlertsCreator::ReservationCreator.new.create_all!
end

Given /^#{capture_model} is reserved hourly$/ do |listing_instance|
  listing = model!(listing_instance)
  listing.action_hourly_booking = true
  listing.save!
end

Given /^#{capture_model} has an hourly price of \$?([0-9\.]+)$/ do |listing_instance, price|
  listing = model!(listing_instance)
  listing.hourly_price = price
  listing.save!
end

Given /^bookings for #{capture_model} do( not)? need to be confirmed$/ do |listing, do_not_require_confirmation|
  listing = model!(listing)
  listing.confirm_reservations = !do_not_require_confirmation.present?
  listing.save!
end

When(/^I cancel (.*) reservation$/) do |number|
  within(:css, "#reservation_#{number}") do
    find(:css, "input[value='Cancel']").click
  end
end

Then /^I should have a cancelled reservation on "([^"]*)"$/ do |date|
  user.cancelled_reservations.collect { |r| Chronic.parse(r.date) }.should include Chronic.parse(date)
end

Given /^Extra fields are prepared for booking$/ do
  ensure_required_custom_attribute_is_present

  User.last.update_column(:instance_profile_type_id, InstanceProfileType.default.first.id)
  User.last.update_column(:mobile_number, '')
  User.last.update_column(:first_name, '')
  User.last.update_column(:last_name, '')
  User.last.update_column(:phone, '')
  User.last.update_column(:company_name, '')
end

When /^I book space for:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  step "I click to confirm the booking"
end

When /^I book space for with extra fields:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  fill_in 'reservation_request_checkout_extra_fields_user_properties_license_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_mobile_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_first_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '12312341'
  fill_in 'reservation_request_checkout_extra_fields_user_company_name', with: '12312341'
  step "I click to confirm the booking"
end

When /^I book space for with extra fields without company_name:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  fill_in 'reservation_request_checkout_extra_fields_user_properties_license_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_mobile_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_first_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '12312341'
  step "I click to confirm the booking"
end

When /^I fail to book space for without extra fields:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  step "I click and fail to confirm the booking"
end

When /^I fail to book space for without extra fields mobile number:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  fill_in 'reservation_request_checkout_extra_fields_user_properties_license_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_first_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_company_name', with: '12312341'
  step "I click and fail to confirm the booking"
end

When /^I fail to book space for without extra fields license number:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  fill_in 'reservation_request_checkout_extra_fields_user_mobile_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_first_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '12312341'
  fill_in 'reservation_request_checkout_extra_fields_user_company_name', with: '12312341'
  step "I click and fail to confirm the booking"
end

When /^I fail to book space for without extra fields last name:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  fill_in 'reservation_request_checkout_extra_fields_user_properties_license_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_mobile_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_first_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '12312341'
  fill_in 'reservation_request_checkout_extra_fields_user_company_name', with: '12312341'
  step "I click and fail to confirm the booking"
end

When /^I fail to book space for without extra fields first name:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details"
  page.should have_css('input#reservation_request_checkout_extra_fields_user_properties_license_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_mobile_number')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_first_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_last_name')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_phone')
  page.should have_css('input#reservation_request_checkout_extra_fields_user_company_name')
  fill_in 'reservation_request_checkout_extra_fields_user_properties_license_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_mobile_number', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Aaa'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '12312341'
  fill_in 'reservation_request_checkout_extra_fields_user_company_name', with: '12312341'
  step "I click and fail to confirm the booking"
end

When /^I book space as new user for:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step 'I sign up as a user in the modal'
  store_model("user", "user", User.last)
  #select "New Zealand", :from => 'reservation_request_country_name'
  page.execute_script "$('select#reservation_request_country_name option[value=\"New Zealand\"]').prop('selected', true).trigger('change');"
  fill_in 'Mobile number', with: '8889983375'
  fill_in 'reservation_request_checkout_extra_fields_user_phone', with: '123123412345'
  fill_in 'reservation_request_checkout_extra_fields_user_last_name', with: 'Name'
  step "I provide reservation credit card details"
  step "I click to confirm the booking"
end

When /^(.*) books a space for that listing$/ do |person|
  listing.reload.reserve!(User.find_by_name(person), [next_regularly_available_day], 1)
end

When /^the (visitor|owner) (confirm|decline|cancel)s the reservation$/ do |user, action|

  if user == "visitor"
    login User.find_by_name("Keith Contractor")
    visit dashboard_user_reservations_path
  else
    login User.find_by_name("Bo Jeanes")
    visit dashboard_company_host_reservations_path
  end
  if action == 'cancel' and user == 'owner'
    within('.dash-head') { click_on 'Confirmed'}
  end
  if action == 'decline'
    step 'I reject reservation with reason'
  else
    click_link_or_button action.capitalize
  end
  page.driver.accept_js_confirms!
end

When /^the reservation expires/ do
  login User.find_by_name("Keith Contractor")
  visit dashboard_user_reservations_path

  reservation = User.find_by_name("Keith Contractor").reservations.first
  reservation.perform_expiry!

  visit dashboard_user_reservations_path
end

When /^I select to book( and review)? space for:$/ do |and_review, table|
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

  step "I click to review the booking" if and_review

end

Then /^the user should have a reservation:$/ do |table|
  user = model!("the user")
  bookings = extract_reservation_options(table)
  listing = bookings.first[:listing]
  reservation = user.reservations.last

  assert_equal listing, reservation.listing
  bookings.each do |booking|
    assert_equal booking[:quantity], reservation.quantity
    period = reservation.periods.detect { |p| p.date == booking[:date] }
    assert period, "Expected there to be a booking on #{booking[:date]} but there was none"

    # Test hourly booking times if hourly reservation
    assert_equal booking[:start_minute], period.start_minute if booking[:start_minute]
    assert_equal booking[:end_minute], period.end_minute if booking[:end_minute]
  end
end

Then /^the reservation subtotal should show \$?([0-9\.,]+)$/ do |cost|
  within '.order-summary .subtotal-amount' do
    assert page.body.should have_content(cost)
  end
end

Then /^the reservation service fee should show \$?([0-9\.,]+)$/ do |cost|
  within '.reservations-review .service-fee-amount' do
    assert page.body.should have_content(cost)
  end
end

Then /^the reservation total should show \$?([0-9\.,]+)$/ do |cost|
  within '.reservations-review .total-amount' do
    assert page.body.should have_content(cost)
  end
end

When /^I click to review the bookings?$/ do
  click_button "Book"
end

When /^I provide reservation credit card details$/ do
  mock_billing_gateway
  fill_in 'reservation_request_card_holder_first_name', with: 'FirstName'
  fill_in 'reservation_request_card_holder_last_name', with: 'LastName'
  fill_in 'reservation_request_card_number', :with => "4242424242424242"
  select '12', from: 'reservation_request_card_exp_month'
  select '2020', from: 'reservation_request_card_exp_year'
  fill_in 'reservation_request_card_code', :with => '411'
  @credit_card_reservation = true
end

When /^I click to confirm the booking$/ do
  click_button "Request Booking"
  page.should have_content('Your reservation has been made')
end

When /^I click and fail to confirm the booking$/ do
  click_button "Request Booking"
  page.should_not have_content('Your reservation has been made')
end

Then(/^I should see the booking confirmation screen for:$/) do |table|
  reservation = extract_reservation_options(table).first
  next unless reservation

  if reservation[:start_minute]
    # Hourly booking
    date = I18n.l(reservation[:date], format: :short)
    start_time = reservation[:start_at].strftime("%-H:%M")
    end_time   = reservation[:end_at].strftime("%-H:%M")
    assert page.has_content?(date), "Expected to see: #{date}"
    assert page.has_content?(start_time), "Expected to see: #{start_time}"
    assert page.has_content?(end_time), "Expected to see: #{end_time}"
  else
    # Daily booking
    assert page.has_content?("#{reservation[:listing].name}")
  end

end

Then(/^I should be asked to sign up before making a booking$/) do
  within '.sign-up-modal' do
    assert page.has_content?("Sign up")
  end
end

When(/^I log in to continue booking$/) do
  click_on 'Already a user?'
  step 'I log in as the user'
end

Then /^#{capture_model} should have(?: ([0-9]+) of)? #{capture_model} reserved for '(.+)'$/ do |user, qty, listing, date|
  user = model!(user)
  qty = qty ? qty.to_i : 1

  listing = model!(listing)

  date = Chronic.parse(date).to_date
  assert listing.reservations.any? { |reservation|
    reservation.owner == user && reservation.quantity == qty && reservation.booked_on?(date)
  }, "Unable to find a reservation for #{listing.name} on #{date}"
end

When /^#{capture_model} is free$/ do |transactable|
  model!(transactable).update_attribute(:action_free_booking, true)
end

Then /^I should see the following reservations in order:$/ do |table|
  found    = all(".dates").map { |b| b.text.gsub(/\n\s*/,' ').gsub("<br>",' ').strip }
  expected = table.raw.flatten

  found.should == expected
end

Then /^a confirm reservation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "just booked your Desk!"
end

Then /^a reservation awaiting confirmation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "your booking is pending confirmation"
end

Then /^a reservation confirmed email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "your booking has been confirmed"
end

Then /^a reservation cancelled email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should =~ Regexp.new(".+ cancelled a booking for '.+' at .+")
end

Then /^a reservation email of cancellation by visitor should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "You just cancelled a booking"
end

Then /^a reservation cancelled by owner email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should =~ Regexp.new("Your booking for '.+' at .+ was cancelled by the host")
end

Then /^a reservation email of cancellation by owner should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should match "You just declined a booking"
end

Then /^a reservation email of rejection should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should match "Can we help"
  last_email_for(email).html_part.body.should include 'We noticed that you declined'
  last_email_for(email).text_part.body.should include 'We noticed that you declined'
end

Then /^a reservation rejected email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should match "Can we help"
  last_email_for(email).html_part.body.should include 'has been declined by the host'
  last_email_for(email).text_part.body.should include 'has been declined by the host'
end

Then /^a new reservation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "just booked your Desk!"
end

Then /^a reservation expiration email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "expired"
end

Then /^I should be redirected to bookings page$/ do
  page.should have_content('Your reservation has been made!')
  assert_includes URI.parse(current_url).path, booking_successful_dashboard_user_reservation_path(Reservation.last)
end

Then /^The second booking should be highlighted$/ do
  page.should have_css(".reservation-list.just-booked #reservation_#{Reservation.last.id}")
  page.should have_css("#reservation_#{Reservation.last.id}")
  page.should have_css(".order", :count => 2)
end

Then /^I should be offered calendar and manage options$/ do
  work_in_modal do
    page.should have_content('Add to Calendar')
    page.should have_content('Manage')
  end
end
