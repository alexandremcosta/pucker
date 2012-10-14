Feature: dealer deals cards

  As a player
  I want to receive cards
  So that I can play

  Scenario: deal two cards
    Given a dealer
    When I receive 2 cards
    Then they should be different

  Scenario: deal fifty-two different cards
    Given a dealer
    When I receive 52 cards
    Then they should be different

  Scenario: deal fifty-third card throws exception
    Given dealer have dealt fifty-two cards
    When I receive 1 card
    Then dealer should throw an exception
