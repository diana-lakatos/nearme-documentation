When(/^I follow the booking link for "([^"]*)"$/) do |date|
  # selector = selector_for("time[datetime=#{date}]")
  date = Time.parse(date).to_date
  find(:xpath, "//time[@datetime='#{date}']/../details/a").click
end


Given /^the workplace has the following bookings:$/ do |table|
  table.hashes.each do |row|
    num = row["Number of Bookings"].to_i
    Given %'#{num} bookings exist with workplace: the workplace, user: the user, date: "#{row["Date"]}"'
  end
end

Then /^I should see the following availability:$/ do |table|
  all("table.bookings td.day").inject({}) do |hash, cell|
    hash.tap do |hash|
      within(:xpath, cell.path) do
        date       = find("time")["datetime"]
        available  = find("details").text
        hash[date] = available
      end
    end
  end.should == table.hashes.first
end
