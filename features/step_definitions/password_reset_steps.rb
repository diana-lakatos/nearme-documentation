When /^I begin to reset the password for that user$/ do
  User.any_instance.expects(:set_reset_password_token).returns('the_token')
  click_on 'Log In'
  work_in_modal do
    click_on 'Reset your password'
    page.should have_content('Fill in your email below')
    find('#user_email').set(user.email)
    click_on 'Reset Password'
  end
  page.should have_content('If the email address is in our system, you will receive an email with instructions on how to reset your password in a few minutes.')
end

Then /^a password reset email should be sent to that user$/ do
  reset_email = last_email_for(user.email)
  reset_email.subject.should include "Reset password"
  reset_email.body.should include edit_user_password_path(reset_password_token: 'the_token')
end

When /^I fill in the password reset form with a new password$/ do
  @old_encrypted_password = user.encrypted_password
  new_token = user.send(:set_reset_password_token)
  visit edit_user_password_path(reset_password_token: new_token)
  fill_in "Password", with: "N3wP4$$word"
  fill_in "Confirm Password", with: "N3wP4$$word"
  click_link_or_button "Change Password"
  page.should have_content('Your password was changed successfully. You are now signed in.')
end

Then /^that users password should be changed$/ do
  user.reload.encrypted_password.should_not eq @old_encrypted_password
end
