Given(/^the date is "([^"]*)"$/) do |date|
  Timecop.travel Date.parse(date)
end

# Return to normal
After do
  Timecop.return
end
