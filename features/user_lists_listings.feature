Feature: User Lists listings
  In order to browse the listings
  As a user
  I want to see a listing of newly-created listings

  Scenario: view listings
    Given a listing exists with name: "Mocra"
    And I am on the home page
    When I follow "Listings"
    Then I should see the following listings in order:
      | Mocra - $50 |
    Given a listing exists with name: "Inspire9"
    When I follow "Listings"
    Then I should see the following listings in order:
      | Inspire9 - $50|
      | Mocra - $50 |

  @wip
  Scenario: Organization member of a locations private organization may see listings
    Given a listing exists for a location with a private organization
    When I log in as a user who is a member of that organization
    And I follow "Listings"
    Then I see that listing listed

  @future
  Scenario: User who is not a member of a locations private organization may not see listings
    Given a listing exists for a location with a private organization
    And I follow "Listings"
    Then I do not see that listing
