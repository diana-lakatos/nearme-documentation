Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard

  Scenario: An unregistered user starts by signing up
    Given I go to the home page
     And  I follow "List Your Space"
     And a listing_type exists with name: "Desk"
     And a location_type exists with name: "Company Office"
     Then I should be at the "Sign Up" step
     When I fill in "Your name" with "Brett Jones"
     And I fill in "Your email address" with "brettjones@email.com"
     And I fill in "Your password" with "password"
     And I fill in "user_password_confirmation" with "password"
     When I press "Sign up"
     Then a user should exist with email: "brettjones@email.com"
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
     And I select "Company Office" from "Location Type"
     And I fill in "Special terms or notes" with "My special terms"
     When I press "Create my Location"
     Then a location should exist with name: "My Office"
     And I should be at the "Listings" step
     When I fill in "Name" with "Conference Room"
     And I fill in "Quantity available" with "2"
     And I fill in "Description" with "Awesome conference room"
     And I fill in "Price per day" with "200"
     And I select "Desk" from "Listing Type"
     And I choose "Yes"
     And I press "Save and Continue"
     Then I should see "Great, your space has been set up!"

