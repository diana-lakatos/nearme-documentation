When(/^I follow the booking link for "([^"]*)"$/) do |date|
  # selector = selector_for("time[datetime=#{date}]")
  date = Time.parse(date).to_date
  When %{I follow "#{date.day}" within "time[datetime='#{date}']"}
end
