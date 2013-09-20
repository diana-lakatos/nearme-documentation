Then /^a shared listing email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = emails_for(email).select { |e| e.subject.include?("shared a listing") }.empty?.should be_true
  else
    last_email = last_email_for(email)
    last_email.html_part.body.should include location_path(@listing.location)
  end
end

# TODO: wonder if we could DRY this a bit...

Then /^an? inquiry user notification email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = emails_for(email).select { |e| e.subject.include?("passed on your inquiry") }.empty?.should be_true
  else
    last_email = last_email_for(email)
  end
end

Then /^an? inquiry creator notification email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = emails_for(email).select { |e| e.subject.include?("New enquiry from") }.empty?.should be_true
  else
    last_email = last_email_for(email)
    last_email.body
  end
end
