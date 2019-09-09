@javascript
Feature: Pointer Inputs
  In order to offer a more user friendly interface
  As a User
  I want to use different input methods for pointers

  Background:
    Given I am signed in as Joe Admin

  Scenario: Creating a templated card including a multiselect input
    Given I create Phrase card "User+*type+*structure" with content "{{+friends}}"
    And I create Phrase card "friends+*right+*input type" with content "multiselect"
    When I edit "Joe User"
    And I select "Joe Admin" from "friends"
    And I press "Save and Close"
    And I go to card "Joe User"
    And I should see "Joe Admin"

  Scenario: Creating a card with radio input
    Given I create Phrase card "friends+*right+*input type" with content "radio"
    When I go to card "Joe User+friends"
    And I choose "Joe Camel"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a card with checkbox input
    Given I create Phrase card "friends+*right+*input type" with content "checkbox"
    When I go to card "Joe User+friends"
    And I check "Joe Camel"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"
    And I edit "Joe User+friends"
    And I uncheck "Joe Camel"
    And I press "Save and Close"
    And I go to card "Joe User+friends"
    Then I should not see "Joe Camel"

# should test:
# switching type before create from pointers
# correct default values for each input type selected / checked / filled in
