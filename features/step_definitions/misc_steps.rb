
Then /^I should see a Google Map$/ do
  page.should have_css(selector_for("a google map"))
end

Given /^Google is working correctly accepting mapping API calls$/ do
  WebMock.reset_webmock
  WebMock.disable_net_connect!(:allow => "maps.google.com")
end

