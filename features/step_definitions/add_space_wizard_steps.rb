When /^(?:|I )follow "([^"]*)" bookable noun$/ do |link|
  click_link "#{link} #{model!("theme").bookable_noun}"
end

Then /^(?:|I )should see "([^"]*)" bookable noun$/ do |text|
  page.should have_content("#{text} #{model!("theme").bookable_noun}")
end
