When /^I begin to reset the password for that user$/ do
  visit new_user_password_path
  fill_in :user_email, with: user.email
  click_link_or_button "Reset Password"
  current_path.should == root_path
  page.should have_content('You will receive an email with instructions about how to reset your password in a few minutes.')
end

Then /^a password reset email should be sent to that user$/ do
  reset_email = mailbox_for(user.email).last
  reset_email.should_not be_nil, "No email sent to #{user.email}, expected an email!"
  reset_email.subject.should include "Reset password"
  reset_email.body.should include edit_user_password_path(:reset_password_token => user.reset_password_token)
end

When /^I fill in the password reset form with a new password$/ do
  @old_encrypted_password = user.encrypted_password
  user.send(:generate_reset_password_token!)
  visit edit_user_password_path(:reset_password_token => user.reset_password_token)
  fill_in "Password", with: "N3wP4$$word"
  fill_in "Confirm Password", with: "N3wP4$$word"
  click_link_or_button "Change Password"
end

Then /^that users password should be changed$/ do
  user.reload.encrypted_password.should_not eq @old_encrypted_password
end
