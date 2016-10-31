@javascript
Feature: User can add document requirements during listing form submission
  Background:
    Given a user exists
      And I am logged in as the user
      And a company exists with creator: the user
      And a location_type exists with name: "Business"
      And a location_type exists with name: "Co-working"
      And a transactable_type_listing exists with name: "Listing"
      And the transactable_type_listing exists
      And document upload enabled

  Scenario: A user can add new listing with document requirements
    Given the location exists with company: the company
      And a transactable exists with location: the location
      And I am browsing transactables
     When I add a new transactable
      And I fill listing form with valid details
      And Fill in document requirement fields
      And I submit the transactable form
      And I should see translation for "flash_messages.manage.listings.desk_added":
        | Variable | Value |
        | bookable_noun | Desk |
     Then Listing with my details should be created

  Scenario: A user can edit existing listing and document requirements
    Given the location exists with company: the company
      And the transactable exists with location: the location
      And Document requirement for transactable exists
      And I am browsing transactables
     When I edit first transactable
      And I provide new listing data
      And Fill in document requirement fields
      And Show form for another document requirement
      And Fill in form for another document requirement
      And I submit the transactable form
      And I should see translation for "flash_messages.manage.listings.listing_updated"
     Then the transactable should be updated
     And Visit edit listing page
     And Updated document requirement should be present in form
     And Two document requirements should be present in form
