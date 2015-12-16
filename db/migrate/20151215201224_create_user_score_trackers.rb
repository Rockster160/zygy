class CreateUserScoreTrackers < ActiveRecord::Migration
  def change
    create_table :user_score_trackers do |t|
      t.belongs_to :user, index: true
      t.belongs_to :game, index: true
      t.integer :at_1, default: 0
      t.integer :at_2, default: 0
      t.integer :at_3, default: 0
      t.integer :at_4, default: 0
      t.integer :at_5, default: 0
      t.integer :at_6, default: 0
      t.integer :at_7, default: 0
      t.integer :at_8, default: 0
      t.integer :at_9, default: 0
      t.integer :at_10, default: 0
      t.integer :at_11, default: 0
      t.integer :at_12, default: 0
      t.integer :at_13, default: 0
      t.integer :at_14, default: 0
      t.integer :at_15, default: 0
      t.integer :all_time_high, default: 0
      t.integer :cumulative, default: 0

      t.timestamps
    end

    add_column :purchases, :game_id, :integer, index: true
    add_column :user_game_scores, :username, :string
  end
end
