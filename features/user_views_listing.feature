Feature: User Views Listing
  Scenario: Viewing a free listing
    Given a listing exists with price_cents: 0
    Then the listing price is shown as Free
