Feature: A user can see the homepage
  In order for Keith to gets lots of money
  As a user
  I want to see the home page and see if they want to pay money

  Scenario: A user can see the homepage
    Given I go to the home page
     Then I should see "Where do you want to work today"

  Scenario: A user can see featured listings
    Given a user exists
      And I am logged in as the user
      And a listing exists with creator: the user, name: "Photo Mania"
      And I am on the listing's page
      And I add the following photos to the listing:
        | File             | Caption                        |
        | boss's desk.jpg  | The Boss' Desk                 |
        | intern chair.jpg | This is where the intern works |
      And a listing exists with name: "No Photo Place"
     When I go to the home page
     Then I should see "Photo Mania"
      And I should not see "No Photo Place"
