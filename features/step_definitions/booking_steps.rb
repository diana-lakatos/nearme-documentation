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
  page.should_not have_css('.booking-module .price .total')
end
