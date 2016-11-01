class AddDefaultToPointsForWinners < ActiveRecord::Migration
  def change
    change_column :tables, :points_for_winners, :text, default: [], null: false
    change_column :tables, :coins_for_winners, :text, default: [], null: false
  end
end
