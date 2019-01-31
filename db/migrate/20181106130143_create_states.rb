class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.integer :total_players,  null: false
      t.integer :position,       null: false
      t.integer :position_over_all, null: false
      t.integer :min_bet,        null: false
      t.integer :total_pot,      null: false
      t.integer :hand_rank,      null: false
      t.decimal :hand_strength,  null: false
      t.decimal :ppot,           null: false
      t.decimal :npot,           null: false
      t.integer :card1_rank,     null: false
      t.integer :card1_suit,     null: false
      t.integer :card2_rank,     null: false
      t.integer :card2_suit,     null: false
      t.integer :flop1_rank,     null: false
      t.integer :flop1_suit,     null: false
      t.integer :flop2_rank,     null: false
      t.integer :flop2_suit,     null: false
      t.integer :flop3_rank,     null: false
      t.integer :flop3_suit,     null: false
      t.integer :turn_rank
      t.integer :turn_suit
      t.integer :river_rank
      t.integer :river_suit
      t.integer :player1_amount, null: false, default: 0
      t.integer :player1_raises, null: false, default: 0
      t.integer :player2_amount, null: false, default: 0
      t.integer :player2_raises, null: false, default: 0
      t.integer :player3_amount, null: false, default: 0
      t.integer :player3_raises, null: false, default: 0
      t.integer :player4_amount, null: false, default: 0
      t.integer :player4_raises, null: false, default: 0
      t.integer :player5_amount, null: false, default: 0
      t.integer :player5_raises, null: false, default: 0
      t.integer :self_amount,    null: false, default: 0
      t.integer :self_raises,    null: false, default: 0
      t.integer :decision_fold,  null: false
      t.integer :decision_check, null: false
      t.integer :decision_raise, null: false
      t.integer :reward,         null: false
      t.string  :player,         null: false
    end
  end
end
