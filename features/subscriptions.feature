@javascript
Feature: A user can subscribe to a service
  In order to become subscriber
  As a user
  I want to subscribe to a service

  Background:
    Given a subscription service is configured
      And a user exists

  Scenario: Subscribing to a service should succeed
    Given I am logged in as the user
      And I went to service page
     When I subscribe to the service
     Then I am subscribed to the service
