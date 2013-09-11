Then /^I should see a Google Map$/ do
  page.should have_css(selector_for("a google map"))
end

Then /^I take a screenshot$/ do
  screenshot_and_open_image
end

Given /^#{capture_model} is deleted$/ do |model|
  # dummy step to make feature scenario more readable :)
end

Given /^#{capture_model} is disabled/ do |model|
  # dummy step to make feature scenario more readable :)
end
