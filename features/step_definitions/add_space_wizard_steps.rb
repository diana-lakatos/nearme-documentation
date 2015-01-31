When /^(?:|I )follow "([^"]*)" bookable noun$/ do |link|
  click_link "#{link} #{TransactableType.first.name}"
end

Then /^(?:|I )should see "([^"]*)" bookable noun$/ do |text|
  page.should have_content("#{text} #{TransactableType.first.name}")
end
