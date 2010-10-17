
Then /^I should see a Google Map$/ do
  page.should have_css(selector_for("a google map"))
end

