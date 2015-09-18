When /^(?:|I )follow "([^"]*)" bookable noun$/ do |link|
  click_link "#{link} #{TransactableType.first.translated_bookable_noun}"
end

Then /^(?:|I )should see "([^"]*)" bookable noun$/ do |text|
  page.should have_content("#{text} #{TransactableType.first.translated_bookable_noun}")
end
