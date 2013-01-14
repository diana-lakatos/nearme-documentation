Given /^(.*) has a listing with an unconfirmed reservation for (.*)$/ do |lister, reserver|
  lister = User.find_by_name(lister)
  reserver = User.find_by_name(reserver)
  @listing = FactoryGirl.create(:listing, creator: lister)
  require 'ruby-debug'; Debugger.start; Debugger.settings[:autoeval] = 1; Debugger.settings[:autolist] = 1; debugger
end

Given /^the listing has the following reservations:$/ do |table|
  table.hashes.each do |row|
    num = row["Number of Reservations"].to_i
    Given %'#{num} reservations exist with listing: the listing, date: "#{row["Date"]}"'
  end
end

Given /^bookings for #{capture_model} do( not)? need to be confirmed$/ do |listing, require_confirmation|
  listing = model!(listing)
  listing.confirm_reservations = require_confirmation.present?
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


When /^I book space for:$/ do |table|
  When %{I select to book space for:}, table
  When %{I click to review the booking}
  When %{I click to confirm the booking}
end

When /^I (confirm|reject|cancel) the reservation$/ do |action|
  visit reservations_dashboard_path
  require 'ruby-debug'; Debugger.start; Debugger.settings[:autoeval] = 1; Debugger.settings[:autolist] = 1; debugger
  click_link_or_button action.capitalize
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
      visit listing_path listing
      year = date.strftime('%Y')
      month = date.strftime('%m').to_i - 1 # - 1 because month JS is (0..11)
      day = date.strftime('%d').to_i
      date_class = ".datepicker-day-#{year}-#{month}-#{day}"

      select qty.to_s, :from => "quantity"

      # Activate the datepicker
      find(:css, ".calendar-wrapper").click

      # Add the day to the seletion
      unless added_dates.include?(date)

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

Then /^I should see the following reservation events in the feed in order:$/ do |table|
  regex = /<img[^>]+>\s*(.*?)\s+booked a desk for the (\d\d [A-Za-z]+, \d\d\d\d).*datetime="(.*?)"/m
  feeds = all("ul.activity-feed li").map do |booked_item|
    user, date, at = *booked_item.native.to_s.scan(regex).first
    [user, Date.parse(date), Time.parse(at)]
  end

  table = table.hashes.map do |row|
    user, date, at = *row.values_at('User', 'For', 'At')
    [user, Date.parse(date), Time.parse(at)]
  end

  feeds.should == table
end

Then /^a confirm reservation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A new reservation requires your confirmation"
end

Then /^a reservation awaiting confirmation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "Your reservation is pending confirmation"
end

Then /^a reservation confirmed email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "Your reservation has been confirmed"
end

Then /^a reservation cancelled email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "A reservation has been cancelled"
end

Then /^a reservation cancelled by owner email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include /Your reservation at (.*) has been cancelled by the owner/
end

Then /^a new reservation email should be sent to (.*)$/ do |email|
  last_email_for(email).subject.should include "You have a new reservation"
end
