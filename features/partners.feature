Feature: There can be many instances of the application
Background:
  Given a admin exists
  Given an instance exists
  And I log in as admin

Scenario: Admin user creates new partner which theme inherits images
  Given I am on the admin instances page
  And an instance has theme with images
  And I browse instance
  And I navigate to new partner form
  When I fill partner form with valid details with theme
  And I press "Create Partner"
  Then I should see created partner show page
  And  Images from instance theme should be copied to partner's theme

Scenario: Admin user does not need to rewrite instance's theme attributes
  Given I am on the admin instances page
  And an instance has theme with images
  And I browse instance
  When I follow "New Partner"
  Then I see a partner form with prefilled values

Scenario: Admin user creates partner without theme
  Given I am on the admin instances page
  And an instance has theme with images
  And I browse instance
  And I follow "New Partner"
  When I fill partner form with valid details without theme
  And I press "Create Partner"
  Then I should see created partner show page
  And Partner should not have its own theme
