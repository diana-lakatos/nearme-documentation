
Feature: A user can book a desk
  In order to hang out with cool dudes and work
  As a user
  I want to book a desk
  
  Background:
    Given a workplace exists
      And the date is "16th October 2010"
  
  Scenario: A logged in user can book a desk
    Given a user exists
      And I am logged in as the user
     When I go to the workplace's page
      And I follow the booking link for "18th October 2010"
     Then I should see "You are making a booking for October 18, 2010"
      And I press "Book"
     Then I should be on the workplace's page
      And a booking should exist with date: "2010-10-18"

  @wip
  Scenario: An anonymous user can log in to book a desk
    Given a user exists  
     When I go to the workplace's page
      And I follow the booking link for "18th October 2010"
  
  
  
  
  
  
