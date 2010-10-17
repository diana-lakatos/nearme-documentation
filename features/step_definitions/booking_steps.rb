When(/^I follow the booking link for "([^"]*)"$/) do |date|
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
  actual_availability = all("table.bookings td.day").inject({}) do |hash, cell|
    hash.tap do |hash|
      within(:xpath, cell.path) do
        date       = find("time")["datetime"]
        available  = find("details").text.strip
        hash[date] = available
      end
    end
  end
  
  table.hashes.each do |date, available|
    actual_availability[date].should == available
  end
end

Then /^I should see the following bookings in order:$/ do |table|
  found = all("ul.bookings li div")
  table.raw.flatten.each_with_index do |booking, index|
    found[index].text.should == booking
  end
end

When(/^I cancel the booking for "([^"]*)"$/) do |date|
  date = Time.parse(date).to_date
  find(:xpath, "//time[@datetime='#{date}']/../../a").click
end

Then /^I should see availability for dates:$/ do |table|
  dates = all("table.bookings td.day time").map {|t| t["datetime"]}
  dates.should == table.raw.flatten
end

Then /^I should not see availability for dates:$/ do |table|
  dates = all("table.bookings td.day time").map {|t| t["datetime"]}  
  table.raw.flatten.each do |date|
    dates.should_not include(date)
  end
end
