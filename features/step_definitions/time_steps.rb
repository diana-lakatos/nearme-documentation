Given(/^the date is "([^"]*)"$/) do |date|
  Timecop.freeze Time.parse(date)
end

# Return to normal
After do
  Timecop.return
end