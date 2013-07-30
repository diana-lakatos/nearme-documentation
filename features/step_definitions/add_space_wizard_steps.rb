When /^(?:|I )follow "([^"]*)" bookable noun$/ do |link|
  click_link "#{link} #{model!("instance").bookable_noun}"
end

Then /^(?:|I )should see "([^"]*)" bookable noun$/ do |text|
  page.should have_content("#{text} #{model!("instance").bookable_noun}")
end

When /^(?:|I )press "([^"]*)" bookable noun$/ do |button|
  click_button("#{button} #{model!("instance").bookable_noun}")
end
