class AddStatsToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :solution_number, :string
    add_column :users, :upline_id, :integer
  end
end
