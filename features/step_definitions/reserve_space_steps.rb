When /^I book space for:$/ do |table|
  When %{I select to book space for:}, table
  When %{I click to review the booking}
  When %{I click to confirm the booking}
end

When /^I select to book space for:$/ do |table|
  next unless table.hashes.length > 0

  added_dates = []
  table.hashes.each do |row|
    date = Chronic.parse(row['Date']).to_date
    date_class = "d-#{date.strftime('%Y-%m-%d')}"
    qty = row['Quantity'].to_i
    qty = 1 if qty < 1
    listing = model!(row['Listing'])

    # Add the day to the seletion
    unless added_dates.include?(date)
      find(:css, ".calendar .#{date_class}").click
      added_dates << date
    end

    # Choose the qty for the listing booking
    within ".listing[data-listing-id=\"#{listing.id}\"]" do
      find(:css, ".booked-day.#{date_class}").click
    end

    fill_in 'booked-day-qty', :with => qty
  end
end

When /^I click to review the bookings?$/ do
  click_link "Review and book now"
  wait_for_ajax
end

When /^I click to confirm the bookings?$/ do
  click_button "Request Booking Now"
  wait_for_ajax
end

When /^#{capture_model} should have(?: ([0-9]+) of)? #{capture_model} reserved for '(.+)'$/ do |user, qty, listing, date|
  user = model!(user)
  qty = qty ? qty.to_i : 1
  listing = model!(listing)
  date = Chronic.parse(date).to_date
  assert listing.reservations.any? { |reservation|
    reservation.owner == user && reservation.periods.any? { |p| p.date == date && p.quantity == qty }
  }
end

Given /^bookings for #{capture_model} do( not)? need to be confirmed$/ do |listing, require_confirmation|
  listing = model!(listing)
  listing.confirm_reservations = require_confirmation.present?
  listing.save!
end
