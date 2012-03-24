Given(/^the date is "([^"]*)"$/) do |date|
  Timecop.freeze Date.parse(date)
end

# Return to normal
After do
  Timecop.return
end
