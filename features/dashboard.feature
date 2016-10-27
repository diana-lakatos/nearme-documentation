@javascript
Feature: As a user of the site
  In order to promote my company
  As a user
  I want to manage my locations

  Background:
    Given a user exists
      And I am logged in as the user
      And a company exists with creator: the user
      And a location_type exists with name: "Business"
      And a location_type exists with name: "Co-working"
      And a transactable_type_listing exists with name: "Listing"
      And the transactable_type_listing exists
      And instance has default availability templates

  Scenario: A user can add new location
    Given a location exists with company: the company
      And a transactable exists with location: the location
      And I am adding new transactable
     When I add a new location
      And I fill location form with valid details
      And I submit the location form
      And I should see "Great, your new location has been added!"
     Then Location with my details should be created

  Scenario: A user can edit existing location

    Given the location exists with company: the company
     And a transactable exists with location: the location
     And I am adding new transactable
     When I edit first location
      And I provide new location data
      And I submit the location form
     Then I should see "Great, your location has been updated!"
      And the location should be updated
      And I remove all locations
      And I should see "You've deleted"

  Scenario: A user can add new listing
    Given the location exists with company: the company
      And a transactable exists with location: the location
      And transactable type has multiple booking types enabled
      And I am browsing transactables
     When I add a new transactable
      And I click on overnight booking tab
      And I fill listing form with valid details
      And I submit the transactable form
      And I should see "Great, your new Desk has been added!"
     Then Listing with my details should be created
      And transactables booking type is overnight

  Scenario: A user can add locations and listings via bulk upload
    Given the location exists with company: the company
      And a transactable exists with location: the location
      And TransactableType is for bulk upload
      And I am browsing bulk upload transactables
     When I upload csv file with locations and transactables
     Then I should see "Import has been scheduled. You'll receive an email when it's done."
      And I should receive data upload report email when finished
      And New locations and transactables from csv should be added

  Scenario: A user can edit existing listing
    Given the location exists with company: the company
      And the transactable exists with location: the location
      And I am browsing transactables
     When I edit first transactable
      And I provide new listing data
      And I submit the transactable form
      And I should see "Great, your listing's details have been updated."
     Then the transactable should be updated
     When I remove first transactable
      And I should see "That listing has been deleted."
     Then the transactable should not exist

  Scenario: A user can disable existing price in listing
    Given a location exists with company: the company
      And transactable type has multiple booking types enabled
      And a transactable exists with location: the location, photos_count: 1
      And I am browsing transactables
     When I edit first transactable
      And I mark 1_day price as free
      And I submit the transactable form
      And I edit first transactable
     Then pricing for 1_day should be free

  Scenario: A user can enable new pricing in listing
    Given a location exists with company: the company
      And transactable type has multiple booking types enabled
      And a transactable exists with location: the location, photos_count: 1
      And I am browsing transactables
     When I edit first transactable
      And I enable 5_day pricing
      And I submit the transactable form
      And I edit first transactable
     Then Listing 5_day pricing should be enabled

  Scenario: A user can set availability rules on a transactable
    Given a location exists with company: the company
    And   a transactable exists with location: the location, photos_count: 1
    And I am browsing transactables
    When I edit first transactable
    And  I select custom availability:
        | Open Time | Close Time | Days |
        | 9:00 am   | 5:00 pm    | 1,2  |
    And I submit the transactable form
    And I should see "Great, your listing's details have been updated."
    Then the transactable should have availability:
        | Open Time | Close Time | Days |
        | 9:00 am   | 17:00      | 1,2  |

  Scenario: A user can't manage blog if blogging is disabled on instance
    Given I visit blog section of dashboard
    Then I should see "Marketplace owner has disabled blog functionality"

  Scenario: A user can manage blog if blogging is enabled on instance
    Given user blogging is enabled for my instance
    Then I should be able to enable my blog

