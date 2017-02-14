Given /^Inquiry alerts exist$/ do
  Utils::DefaultAlertsCreator::InquiryCreator.new.create_all!
end

Given /^Listing alerts exist$/ do
  FactoryGirl.create(:instance_admin_role_administrator) unless InstanceAdminRole.where(name: 'Administrator').count > 0
  Utils::DefaultAlertsCreator::ListingCreator.new.create_all!
end

Then /^a shared listing email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = last_email_with_subject(email, 'shared a listing')
  else
    last_email = last_email_for(email)
    last_email.html_part.body.should include @listing.decorate.show_path
  end
end

# TODO: wonder if we could DRY this a bit...

Then /^an? inquiry user notification email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  last_email = last_email_for(email)
  if no_email
    last_email = last_email_with_subject(email, 'passed on your inquiry')
  end
end

Then /^an? inquiry creator notification email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = last_email_with_subject(email, 'New enquiry from')
  else
    last_email = last_email_for(email)
    last_email.body
  end
end
