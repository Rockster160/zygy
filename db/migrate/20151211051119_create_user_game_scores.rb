class CreateUserGameScores < ActiveRecord::Migration
  def change
    create_table :user_game_scores do |t|
      t.belongs_to :user, index: true
      t.integer :game_id, index: true
      t.integer :score

      t.timestamps
    end
  end
end
