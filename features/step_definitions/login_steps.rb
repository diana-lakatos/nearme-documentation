Then /^(?:|I )should see "([^"]*)" platform name$/ do |text|
  page.should have_content("#{text} #{model!("instance").name}")
end
