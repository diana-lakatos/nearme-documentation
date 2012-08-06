Feature: A user can add photos to a listing
  In order to give coworkers a feel for the listing
  As a listing manager
  I want to add photos to the listing

  Background:
    Given a user exists
      And a listing exists with creator: the user

  Scenario: Adding photos to a work place
    Given I am logged in as the user
      And I am on the listing's page
     When I follow "Add/Manage Photos"
     Then I should see 0 listing photos
     When I attach the photo "boss's desk.jpg" to "New Photo"
     When I fill in "Caption" with "The Boss' Desk"
      And I press "Upload"
     Then I should see 1 listing photo
      And the listing photos should be:
        | The Boss' Desk |
     When I attach the photo "intern chair.jpg" to "New Photo"
     When I fill in "Caption" with "This is where the intern works"
      And I press "Upload"
     Then I should see 2 listing photos
      And the listing photos should be:
        | The Boss' Desk                 |
        | This is where the intern works |

  Scenario: Deleting photos
   Given I am logged in as the user
     And I am on the listing's page
    When I add the following photos to the listing:
      | File             | Caption                       |
      | boss's desk.jpg  | The Boss' Desk                 |
      | intern chair.jpg | This is where the intern works |
    And I go to the listing's page
    And I follow "Add/Manage Photos"
    Then I should see 2 listing photos
    When I press "Delete" within the first photo box
    Then I should see 1 listing photo

  Scenario: A hacker cant edit a listing
    Given a user: "hacker" exists
      And I am logged in as the user: "hacker"
     When I go to the listing's edit page
      And I should not see "New Photo"
      And I should see "Could not find listing"

