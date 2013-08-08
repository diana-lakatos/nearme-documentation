Then /^I should see a Google Map$/ do
  page.should have_css(selector_for("a google map"))
end

Given /^#{capture_model} is deleted$/ do |model|
  # dummy step to make feature scenario more readable :)
end
