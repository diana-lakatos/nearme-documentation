Given /^no bookings exists$/ do
  @bookings = nil # express the regexp above with the code you wish you had
end

Then /^I should see a search form$/ do
  page.has_selector?('form #search')
end

Then /^I should see a free booking module$/ do
  within '.booking-module .label' do
    assert page.has_content?('Free')
  end
  within '.booking-module .price .total' do
    assert page.has_content?('0.00')
  end
end
