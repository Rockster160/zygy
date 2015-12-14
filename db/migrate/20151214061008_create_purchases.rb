class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.belongs_to :user, index: true
      t.string :amount

      t.timestamps
    end
  end
end
