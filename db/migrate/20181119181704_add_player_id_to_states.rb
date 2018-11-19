class AddPlayerIdToStates < ActiveRecord::Migration
  def change
    add_column :states, :player, :string
  end
end
