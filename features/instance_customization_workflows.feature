@javascript
Feature: We can define customization for instance and we can define workflows to trigger
  Background:
    Given a user exists
    And I am logged in as the user
    Given a form_configuration_customization exists
    Given a custom_model_type_refer_contact exists
    Given a page_contact_form exists
    Given a instance_view_email_html_blank exists

  Scenario: A user can fill in form and will get an email
    When I visit 'refer-contact' page
    And I fill in all fields and submit form
    Then I should be redirected to home_page
    And I should get an email
    And customization is stored in database
