@javascript
Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard

Scenario: An unregistered user starts a draft, comes back to it, and saves it
    Given a location_type exists with name: "Business"
    And a transactable_type_listing exists with name: "Listing"
    And a country_nz exists
    And a required_user_custom_attribute exists with name: "user_custom_attribute", attribute_type: "string", html_tag: "input", label: "Custom Att"
    And a form_component_with_user_custom_attributes exists with form_componentable: the transactable_type_listing
   When I go to the home page
    And I follow "List Your" bookable noun
    And I sign up as a user in the modal
    And I fill in valid space details
    And I press "Submit"
    Then I should see "Please complete all fields! Alternatively, you can Save for later."
    And I fill in "Custom Att" with "MyCustomAttributeIsHere"
    And I press "Submit"
    And I should see "Your Desk was listed!"
