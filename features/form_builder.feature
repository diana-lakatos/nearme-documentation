@javascript
Feature: A complex form configuration exists and we can use it

  Scenario: User sign up and update profile
    Given Form builder configuration is in place
     And enquirer exists
     And I am logged in as enquirer
     And I go to the account settings page
    When I update my profile and trigger all validation errors
    Then All error messages for the form are correctly displayed
    When I upload images and attachments without filling rest of the form
    Then All images and attachments are properly stored and persisted
    When I add two and remove one customization and submit form again to see what happens
    Then The previously uploaded images and attachments stay untouched and new ones are persisted
    When I remove first set of images and swap the other
    Then The first set is removed and other is swappped
    When I fill rest of the form
    Then all data is properly stored in DB and the form is re-rendered with those value filled
