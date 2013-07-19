Given /^(.*) has a( |n un)confirmed reservation for (.*)$/ do |lister, confirmed, reserver|
  lister = User.find_by_name(lister)
  reserver = User.find_by_name(reserver)
  @listing = FactoryGirl.create(:listing)
  @listing.creator = lister
  reservation = @listing.reserve!(reserver, [next_regularly_available_day], 1)
  unless confirmed != " "
    reservation.confirm!
    reservation.save
  end

end

Then /^I should see a link "(.*?)"$/ do |link|
  page.should have_content(link)
end

Given /^#{capture_model} is reserved hourly$/ do |listing_instance|
  listing = model!(listing_instance)
  listing.hourly_reservations = true
  listing.save!
end

Given /^#{capture_model} has an hourly price of \$?([0-9\.]+)$/ do |listing_instance, price|
  listing = model!(listing_instance)
  listing.hourly_price = price
  listing.save!
end

Given /^the listing has the following reservations:$/ do |table|
  table.hashes.each do |row|
    num = row["Number of Reservations"].to_i
    step "#{num} reservations exist with listing: the listing, date: \"#{row['Date']}\""
  end
end

Given /^bookings for #{capture_model} do( not)? need to be confirmed$/ do |listing, do_not_require_confirmation|
  listing = model!(listing)
  listing.confirm_reservations = !do_not_require_confirmation.present?
  listing.save!
end

When(/^I follow the reservation link for "([^"]*)"$/) do |date|
  date = Date.parse(date)
  find(:css, ".calendar .d-#{date.strftime('%Y-%m-%d')}").click
  find(:css, ".booked-day.d-#{date.strftime('%Y-%m-%d')}").click
  fill_in 'booked-day-qty', :with => '1'
  click_link "Review and book now"
end

When(/^I try to book at #{capture_model} on "([^"]*)"$/) do |listing_instance, date|
  listing = model!(listing_instance)
  date = Date.parse(date)
  visit "/listings/#{listing.to_param}/reservations/new?date=#{date}"
end

When(/^I cancel the reservation for "([^"]*)"$/) do |date|
  date = Date.parse(date)
  within(:css, "li[data-date='#{date}']") do
    find(:css, "input[value='Cancel']").click
  end
end

Then /^I should have a cancelled reservation on "([^"]*)"$/ do |date|
  user.cancelled_reservations.collect { |r| Chronic.parse(r.date) }.should include Chronic.parse(date)
end


When /^I book space( with credit card)? for:$/ do |with_credit_card, table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step "I provide reservation credit card details" if with_credit_card
  step "I click to confirm the booking"
end

When /^I book space as new user for:$/ do |table|
  step "I select to book space for:", table
  step "I click to review the booking"
  step 'I sign up as a user in the modal'
  store_model("user", "user", User.last)
  step "I click to confirm the booking"
end

When /^(.*) books a space for that listing$/ do |person|
  listing.reserve!(User.find_by_name(person), [next_regularly_available_day], 1)
end

When /^the (visitor|owner) (confirm|decline|cancel)s the reservation$/ do |user, action|

  if user == "visitor"
    login User.find_by_name("Keith Contractor")
    visit bookings_dashboard_path
  else
    login User.find_by_name("Bo Jeanes")
    visit manage_guests_dashboard_path
  end
  if action == 'cancel' and user == 'owner'
    within('.guest_filter') { click_on 'Confirmed'}
  end
  click_link_or_button action.capitalize
  page.driver.accept_js_confirms!
end

When /^the reservation expires/ do
  login User.find_by_name("Keith Contractor")
  visit bookings_dashboard_path

  reservation = User.find_by_name("Keith Contractor").reservations.first
  reservation.perform_expiry!

  visit bookings_dashboard_path
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

Then /^the reservation subtotal should show \$?([0-9\.]+)$/ do |cost|
  within '.space-reservation-modal .subtotal-amount' do
    assert page.has_content?(cost)
  end
end

Then /^the reservation service fee should show \$?([0-9\.]+)$/ do |cost|
  within '.space-reservation-modal .service-fee-amount' do
    assert page.has_content?(cost)
  end
end

Then /^the reservation total should show \$?([0-9\.]+)$/ do |cost|
  within '.space-reservation-modal .total-amount' do
    assert page.has_content?(cost)
  end
end

When /^I click to review the bookings?$/ do
  click_link "Book"
end

When /^I provide reservation credit card details$/ do
  mock_billing_gateway

  choose 'payment_method_credit_card'
  fill_in 'card_number', :with => "4111111111111111"
  fill_in 'card_expires', :with => '1218'
  fill_in 'card_code', :with => '123'
  @credit_card_reservation = true
end

When /^I click to confirm the bookings?( with credit card)?$/ do |credit_card|
  wait_modal_loaded '.space-reservation-modal'
  if !credit_card && !@credit_card_reservation
    choose 'payment_method_manual'
    page.should_not have_content('Credit Card Number')
  end
  click_button "Request Booking"
  page.should have_content('Your reservation has been made!')
end

Then(/^I should see the booking confirmation screen for:$/) do |table|
  reservation = extract_reservation_options(table).first
  next unless reservation
  within '.space-reservation-modal' do
    if reservation[:start_minute]
      # Hourly booking
      date = reservation[:date].strftime("%B %-e")
      start_time = reservation[:start_at].strftime("%l:%M%P")
      end_time   = reservation[:end_at].strftime("%l:%M%P").strip
      assert page.has_content?(date), "Expected to see: #{date}"
      assert page.has_content?(start_time), "Expected to see: #{start_time}"
      assert page.has_content?(end_time), "Expected to see: #{end_time}"
    else
      # Daily booking
      assert page.has_content?("#{reservation[:quantity]} #{reservation[:listing].name}")
    end
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

When /^#{capture_model} should have(?: ([0-9]+) of)? #{capture_model} reserved for '(.+)'$/ do |user, qty, listing, date|
  user = User.last
  qty = qty ? qty.to_i : 1

  listing = model!(listing)

  date = Chronic.parse(date).to_date
  assert listing.reservations.any? { |reservation|
    reservation.owner == user && reservation.quantity == qty && reservation.booked_on?(date)
  }, "Unable to find a reservation for #{listing.name} on #{date}"
end

Then (/^I should not see the reservation link for "([^"]*)"$/) do |date|
  date = Date.parse(date)
  page.should_not have_xpath("//time[@datetime='#{date}']/../details/a")
end

Then /^I should see the following availability:$/ do |table|
  actual_availability = all("table.reservations td.day").inject({}) do |hash, cell|
    hash.tap do |hash|
      within(:xpath, cell.path) do
        date       = find("time")["datetime"]
        available  = find(".details").text.strip
        hash[date] = available
      end
    end
  end

  table.hashes.each do |date, available|
    actual_availability[date].should == available
  end
end

Then /^I should see the following reservations in order:$/ do |table|
  found    = all("ul.reservations li > p").map { |b| b.text.gsub(/\n\s*/,' ').strip }
  expected = table.raw.flatten

  found.should == expected
end

Then /^I should see availability for dates:$/ do |table|
  dates = all("table.reservations td.day time").map {|t| t["datetime"]}
  dates.should == table.raw.flatten
end

Then /^I should not see availability for dates:$/ do |table|
  dates = all("table.reservations td.day time").map {|t| t["datetime"]}
  table.raw.flatten.each do |date|
    dates.should_not include(date)
  end
end

Then /^a confirm reservation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A booking requires your confirmation"
end

Then /^a reservation awaiting confirmation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A booking you made is pending confirmation"
end

Then /^a reservation confirmed email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A booking you made has been confirmed"
end

Then /^a reservation cancelled email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A guest has cancelled a booking"
end

Then /^a reservation cancelled by owner email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should match "A booking you made has been cancelled by the owner"
end

Then /^a reservation rejected email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should match "A booking you made has been rejected"
end

Then /^a new reservation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A guest has made a booking"
end

Then /^a reservation expiration email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "expired"
end

Before('@timecop') do
  Timecop.freeze Time.now
end

After('@timecop') do
  Timecop.return
end
