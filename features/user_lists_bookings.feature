Feature: User Lists bookings
  In order to browse the bookings
  As a user
  I want to see a listing of newly-created bookings

  Scenario: no bookings
    Given no bookings exists
    When I go to the bookings page
    Then I should see a search form 
