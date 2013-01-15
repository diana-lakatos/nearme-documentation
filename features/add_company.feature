Feature: A user can add a company
  In order to let people easily list a space
  As a user
  I want to be able to create a company to list a space

  Background:
    Given a user exists

  Scenario: A registered user can create a company
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

  Scenario: A registered user can't create a company with a description that is longer than 250 characters limit
    Given I am logged in as a user
     And  I go to the home page
     And  I follow "List Your Space"
     And I should be at the "Company" step
     When I fill in "Your company name" with "My Company"
     And I fill in "Company website URL" with "http://google.com"
     And I fill in "Company email" with "email@mycompany.com"
     And I fill in "Company description" with "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sagittis sollicitudin lacinia. Donec nulla metus, auctor eget malesuada bibendum, tempor a arcu. Fusce in libero vitae ligula accumsan imperdiet. Fusce quis erat augue. Etiam volutpat."
     When I press "Create my Company"
     Then a company should not exist with name: "My Company"
     Then I should see "is too long (maximum is 250 characters)"

