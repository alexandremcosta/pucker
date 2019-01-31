# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20181106130143) do

  create_table "states", :force => true do |t|
    t.integer "total_players",                    :null => false
    t.integer "position",                         :null => false
    t.integer "position_over_all",                :null => false
    t.integer "min_bet",                          :null => false
    t.integer "total_pot",                        :null => false
    t.integer "hand_rank",                        :null => false
    t.decimal "hand_strength",                    :null => false
    t.decimal "ppot",                             :null => false
    t.decimal "npot",                             :null => false
    t.integer "card1_rank",                       :null => false
    t.integer "card1_suit",                       :null => false
    t.integer "card2_rank",                       :null => false
    t.integer "card2_suit",                       :null => false
    t.integer "flop1_rank",                       :null => false
    t.integer "flop1_suit",                       :null => false
    t.integer "flop2_rank",                       :null => false
    t.integer "flop2_suit",                       :null => false
    t.integer "flop3_rank",                       :null => false
    t.integer "flop3_suit",                       :null => false
    t.integer "turn_rank"
    t.integer "turn_suit"
    t.integer "river_rank"
    t.integer "river_suit"
    t.integer "player1_amount",    :default => 0, :null => false
    t.integer "player1_raises",    :default => 0, :null => false
    t.integer "player2_amount",    :default => 0, :null => false
    t.integer "player2_raises",    :default => 0, :null => false
    t.integer "player3_amount",    :default => 0, :null => false
    t.integer "player3_raises",    :default => 0, :null => false
    t.integer "player4_amount",    :default => 0, :null => false
    t.integer "player4_raises",    :default => 0, :null => false
    t.integer "player5_amount",    :default => 0, :null => false
    t.integer "player5_raises",    :default => 0, :null => false
    t.integer "self_amount",       :default => 0, :null => false
    t.integer "self_raises",       :default => 0, :null => false
    t.integer "decision_fold",                    :null => false
    t.integer "decision_check",                   :null => false
    t.integer "decision_raise",                   :null => false
    t.integer "reward",                           :null => false
    t.string  "player",                           :null => false
  end

end
