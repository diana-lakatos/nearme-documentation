Feature: A user can add a location to a company
  In order to let people easily list a space
  As a user
  I want to be able to create a company to list a space

  Background:
    Given a user exists

  Scenario: A registered user can create a location for a company
    Given I am logged in as a user
     And  I go to the home page
     And  I follow "List Your Space"
     And I should be at the "Company" step
     When I fill in "Your company name" with "My Company"
     And I fill in "Company website URL" with "http://google.com"
     And I fill in "Company email" with "email@mycompany.com"
     And I fill in "Company description" with "My Description"
     When I press "Create my Company"
     Then a company should exist with name: "My Company"
     And I should be at the "Location" step
     When I fill in "Location name" with "My Office"
     And I fill in "Location address" with "usa"
     And I fill in "Location description" with "Awesome space"
     And I fill in "Booking email" with "bookings@mycompany.com"
     And I fill in "Booking phone #" with "123456"
     And I fill in "Special terms or notes" with "My special terms"
     When I press "Create my Location"
     Then a location should exist with name: "My Office"

  Scenario: A registered user can't create a location  with a description that is longer than 250 characters limit
     Given I am logged in as a user
     And  I go to the home page
     And  I follow "List Your Space"
     And I should be at the "Company" step
     When I fill in "Your company name" with "My Company"
     And I fill in "Company website URL" with "http://google.com"
     And I fill in "Company email" with "email@mycompany.com"
     And I fill in "Company description" with "My Description"
     When I press "Create my Company"
     Then a company should exist with name: "My Company"
     Then a company should exist with name: "My Company"
     And I should be at the "Location" step
     When I fill in "Location name" with "My Office"
     And I fill in "Location address" with "usa"
     And I fill in "Location description" with "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sagittis sollicitudin lacinia. Donec nulla metus, auctor eget malesuada bibendum, tempor a arcu. Fusce in libero vitae ligula accumsan imperdiet. Fusce quis erat augue. Etiam volutpat."
     And I fill in "Booking email" with "bookings@mycompany.com"
     And I fill in "Booking phone #" with "123456"
     And I fill in "Special terms or notes" with "My special terms"
     When I press "Create my Location"
     Then a location should not exist with name: "My Office"
     Then I should see "is too long (maximum is 250 characters)"
