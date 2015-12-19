class AddGameIdToUserScoreTracker < ActiveRecord::Migration
  def change
    add_column :user_score_trackers, :game_id, :integer, index: true
    add_column :purchase_trackers, :game_id, :integer, index: true

    add_column :user_score_trackers, :user_id, :integer, index: true
    add_column :purchase_trackers, :user_id, :integer, index: true
  end
end
