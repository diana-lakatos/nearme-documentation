Then /^a shared listing email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = mailbox_for(email).select { |e| e.subject.include?("shared a listing") }.should be_empty
  else
    last_email = mailbox_for(email).last
    last_email.subject.should include "shared a listing"
    last_email.html_part.body.should include listing_path(@listing)
    last_email.html_part.body
  end
end

# TODO: wonder if we could DRY this a bit...

Then /^an? inquiry user notification email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = mailbox_for(email).select { |e| e.subject.include?("passed on your inquiry") }.should be_empty
  else
    last_email = mailbox_for(email).last
    last_email.should_not be_nil, "No emails sent to #{email}, expected an email"
    last_email.subject.should include "passed on your inquiry"
    last_email.body
  end
end

Then /^an? inquiry creator notification email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = mailbox_for(email).select { |e| e.subject.include?("New enquiry from") }.should be_empty
  else
    last_email = mailbox_for(email).last
    last_email.should_not be_nil, "No emails sent to #{email}, expected an email"
    last_email.subject.should include "New enquiry from"
    last_email.body
  end
end
