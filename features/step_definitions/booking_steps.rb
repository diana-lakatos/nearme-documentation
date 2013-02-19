Given /^no bookings exists$/ do
  @bookings = nil # express the regexp above with the code you wish you had
end

Then /^I should see a search form$/ do
  page.has_selector?('form #search')
end
