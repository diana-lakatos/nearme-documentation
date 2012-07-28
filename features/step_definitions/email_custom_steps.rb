Then /^a shared listing email is( not)? sent to "([^"]+)"$/ do |no_email, email|
  if no_email
    last_email = mailbox_for(email).select { |e| e.subject.include?("shared a listing") }.should be_empty
  else
    last_email = mailbox_for(email).last
    last_email.subject.should include "shared a listing"
    last_email.body.should include workplace_path(@listing)
    last_email.body
  end
end
