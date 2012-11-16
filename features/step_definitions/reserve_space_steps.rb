When /^I choose to book space for:$/ do |table|
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

  click_link "Review and book now"
  click_button "Request Booking Now"
  wait_until {
    page.evaluate_script('jQuery.active') == 0
  }
end

Given /^random test$/ do
  raise model!('the user').inspect
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
