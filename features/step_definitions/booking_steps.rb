When(/^I follow the booking link for "([^"]*)"$/) do |date|
  # selector = selector_for("time[datetime=#{date}]")
  date = Time.parse(date).to_date
  When %{I follow "#{date.day}" within "time[datetime='#{date}']"}
end


Given /^the workplace has the following bookings:$/ do |table|
  table.hashes.each do |row|
    num = row["Number of Bookings"].to_i
    Given %'#{num} bookings exist with workplace: the workplace, user: the user, date: "#{row["Date"]}"'
  end
end

Then /^I should see the following availability:$/ do |table|
  # all("table.bookings td.day")
end
