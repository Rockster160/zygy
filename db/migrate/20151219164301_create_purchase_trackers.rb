class CreatePurchaseTrackers < ActiveRecord::Migration
  def change
    create_table :purchase_trackers do |t|
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
      t.integer :cumulative, default: 0

      t.timestamps
    end

    remove_column :purchases, :amount, :string
    add_column :purchases, :amount, :integer, default: 0
    add_column :user_game_scores, :level, :integer
  end
end
