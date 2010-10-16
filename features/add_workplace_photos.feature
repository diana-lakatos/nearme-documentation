@wip
Feature: A user can add photos to a workplace
  In order to give coworkers a feel for the workplace
  As a workplace manager
  I want to add photos to the workplace listing

  Background:
    Given a user exists
      And I am logged in as the user
      And a workplace exists with creator: the user
      And I am on the workplace's page

  Scenario: Adding photos to a work place
     When I follow "Manage Workplace Photos"
     Then I should see 0 workplace photos
     When I attach the photo "boss's desk.jpg" to "New Photo"
      And I press "Upload"
     Then I should see 1 workplace photo
      And the workplace photos should be:
        | boss's desk.jpg |
     When I attach the photo "intern chair.jpg" to "New Photo"
      And I press "Upload"
     Then I should see 2 workplace photos
      And the workplace photos should be:
        | boss's desk.jpg  |
        | intern chair.jpg |
