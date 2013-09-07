Run options: include {:wip=>true}

All examples were filtered out; ignoring {:wip=>true}

Pucker::Player
  #get_from_stack
    when player has more
      should get amount
    when player has less
      should zero stack
      should desactivate player
  #set_hand
    should put 2 cards on player's hand

Pucker::Game
  #initialize
    should have 5 players by default
    should allow definition of number of players
  #play
    deciding what to spec out (PENDING: No reason given)
  private methods
    #collect_blinds
      should == 30

Pucker::Dealer
  #deal
    deals cards
    deals 52 different cards
    doesn't deal 53 cards
  #reset
    allows dealer to continue dealing
    should deal cards in different order

Pucker::PlayerGroup
  #[]
    should delegate to container
  #set_hands
    should give 2 cards to each player

Pending:
  Pucker::Game#play deciding what to spec out
    # No reason given
    # ./spec/pucker/game_spec.rb:19

Finished in 0.1 seconds
15 examples, 0 failures, 1 pending
