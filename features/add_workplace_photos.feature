Feature: A user can add photos to a workplace
  In order to give coworkers a feel for the workplace
  As a workplace manager
  I want to add photos to the workplace listing

  Background:
    Given a user exists
      And a workplace exists with creator: the user

  Scenario: Adding photos to a work place
    Given I am logged in as the user
      And I am on the workplace's page
     When I follow "Manage Workplace Photos"
     Then I should see 0 workplace photos
     When I attach the photo "boss's desk.jpg" to "New Photo"
     When I fill in "Description" with "The Boss' Desk"
      And I press "Upload"
     Then I should see 1 workplace photo
      And the workplace photos should be:
        | The Boss' Desk |
     When I attach the photo "intern chair.jpg" to "New Photo"
     When I fill in "Description" with "This is where the intern works"
      And I press "Upload"
     Then I should see 2 workplace photos
      And the workplace photos should be:
        | The Boss' Desk                 |
        | This is where the intern works |

  Scenario: Deleting photos
   Given I am logged in as the user
     And I am on the workplace's page
    When I add the following photos to the workplace:
      | File             | Description                    |
      | boss's desk.jpg  | The Boss' Desk                 |
      | intern chair.jpg | This is where the intern works |
    And I go to the workplace's page
    And I follow "Manage Workplace Photos"
    Then I should see 2 workplace photos
    When I press "Delete" within the first photo box
    Then I should see 1 workplace photo

  Scenario: A hacker cant edit a workplace
    Given a user: "hacker" exists
      And I am logged in as the user: "hacker"
     When I go to the workplace's edit page
      And I should not see "New Photo"
      And I should see "Could not find workplace"

