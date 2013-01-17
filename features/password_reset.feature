Feature: A user can reset their password
  In order to login if they forget their password
  As a user
  I want to reset my password

  Background:
    Given a user exists with email: "real@email.com"

  Scenario: A user can reset their password
    Given I go to the home page
      And I follow "Log in"
      And I follow "Reset your password"
      When I fill in "Email" with "real@email.com"
      And I press "Reset Password"
      Then I should see "You will receive an email with instructions"
      And 1 emails should be delivered to that user
      And the email should contain "Change my password"
      When I follow the password reset link for that user
      And I fill in "Password" with "mynewpassword"
      And I fill in "Confirm Password" with "mynewpassword"
      And I press "Change Password"
      Then I should see "Your password was changed successfully"
      And that user should have password "mynewpassword"

