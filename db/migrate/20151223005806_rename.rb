class Rename < ActiveRecord::Migration
  def change
    rename_column :users, :solution_number, :zygy_id
  end
end
