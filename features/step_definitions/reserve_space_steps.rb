When /^I book space for:$/ do |table|
  When %{I select to book space for:}, table
  When %{I click to review the booking}
  When %{I click to confirm the booking}
end

When /^I select to book space( using the advanced view)? for:$/ do |advanced, table|
  next unless table.hashes.length > 0

  added_dates = []
  table.hashes.each do |row|

    date = Chronic.parse(row['Date']).to_date
    qty = row['Quantity'].to_i
    qty = 1 if qty < 1
    listing = model!(row['Listing'])

    if advanced 
      date_class = "d-#{date.strftime('%Y-%m-%d')}"

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

    else
      year = date.strftime('%Y')
      month = date.strftime('%m').to_i - 1 # - 1 because month JS is (0..11)
      day = date.strftime('%d').to_i
      date_class = ".datepicker-day-#{year}-#{month}-#{day}"

      select qty.to_s, :from => "quantity"

      # Activate the datepicker
      find(:css, ".calendar-wrapper").click

      # Add the day to the seletion
      unless added_dates.include?(date)

        find(:css, ".datepicker-next").click
        find(:css, date_class).click
        added_dates << date

      end
    end

  end
end

When /^I click to review the bookings?$/ do
  click_link "Book"
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

Then /^the space owner and booker should be notified$/ do
  nth = "1st"
  latest_reservation = Reservation.last
  steps %Q{
    Then the #{nth} email should be delivered to the listing's owner
    And the #{nth} email should have subject: "[DesksNear.Me] A new reservation requires your confirmation"
    And the #{nth} email should contain the listing's owner's name
    And the #{nth} email should contain "#{latest_reservation.owner.name}"
    And the #{nth} email should contain "made a reservation"
    And the #{nth} email should contain "#{latest_reservation.date.strftime('%B %-e')}
  }
end
