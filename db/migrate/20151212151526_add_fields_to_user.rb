class AddFieldsToUser < ActiveRecord::Migration
  def change
    create_table :security_keys do |t|
      t.belongs_to :user, index: true
      t.belongs_to :game, index: true
      t.string :authorization_code

      t.timestamps
    end

    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
