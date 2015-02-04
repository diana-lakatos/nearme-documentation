Given /^Alerts for sign up exist$/ do
  Utils::DefaultAlertsCreator::SignUpCreator.new.create_email_verification_email!
end

Then /^(?:|I )should see "([^"]*)" platform name$/ do |text|
  page.should have_content("#{text} #{model!("instance").name}")
end

