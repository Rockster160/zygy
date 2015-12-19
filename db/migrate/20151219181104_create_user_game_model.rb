class CreateUserGameModel < ActiveRecord::Migration
  def change
    create_table :user_games do |t|
      t.belongs_to :user, index: true
      t.belongs_to :game, index: true

      t.string :username

      t.timestamps
    end

    remove_column :user_game_scores, :user_id
    remove_column :user_score_trackers, :user_id
    remove_column :security_keys, :user_id
    remove_column :purchases, :user_id
    remove_column :purchase_trackers, :user_id

    remove_column :user_game_scores, :game_id
    remove_column :user_score_trackers, :game_id
    remove_column :security_keys, :game_id
    remove_column :purchases, :game_id
    remove_column :purchase_trackers, :game_id

    add_column :user_game_scores, :user_game_id, :integer, index: true
    add_column :user_score_trackers, :user_game_id, :integer, index: true
    add_column :security_keys, :user_game_id, :integer, index: true
    add_column :purchases, :user_game_id, :integer, index: true
    add_column :purchase_trackers, :user_game_id, :integer, index: true
  end
end
