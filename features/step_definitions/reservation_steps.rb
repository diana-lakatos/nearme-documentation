When(/^I follow the reservation link for "([^"]*)"$/) do |date|
  date = Date.parse(date)
  find(:xpath, "//time[@datetime='#{date}']/../div/a").click
end

Then (/^I should not see the reservation link for "([^"]*)"$/) do |date|
  date = Date.parse(date)
  page.should_not have_xpath("//time[@datetime='#{date}']/../details/a")
end

When(/^I try to book at #{capture_model} on "([^"]*)"$/) do |listing_instance, date|
  listing = model!(listing_instance)
  date = Date.parse(date)
  visit "/listings/#{listing.to_param}/reservations/new?date=#{date}"
end


Given /^the listing has the following reservations:$/ do |table|
  table.hashes.each do |row|
    num = row["Number of Reservations"].to_i
    Given %'#{num} reservations exist with listing: the listing, date: "#{row["Date"]}"'
  end
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

When(/^I cancel the reservation for "([^"]*)"$/) do |date|
  date = Date.parse(date)
  within(:css, "li[data-date='#{date}']") do
    find(:css, "input[value='Cancel']").click
  end
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

Given /^the following reservations are made for the listing:$/ do |table|
  users = {}

  table.hashes.each do |row|
    user = users[row['User']] ||= FactoryGirl.create(:user, :name => row['User'])
    Timecop.freeze(Time.parse row['At'])
    model!('the listing').reservations.create(
      :user      => user,
      :date      => Date.parse(row['For'])
    )

    Timecop.return
  end
end

Then /^I should see the following reservation events in the feed in order:$/ do |table|
  regex = /<img[^>]+>\s*(.*?)\s+booked a desk for the (\d\d [A-Za-z]+, \d\d\d\d).*datetime="(.*?)"/m
  feeds = all("dl.activity_feed dd.feed_item.booked").map do |booked_item|
    user, date, at = *booked_item.native.to_s.scan(regex).first
    [user, Date.parse(date), Time.parse(at)]
  end

  table = table.hashes.map do |row|
    user, date, at = *row.values_at('User', 'For', 'At')
    [user, Date.parse(date), Time.parse(at)]
  end

  feeds.should == table
end

