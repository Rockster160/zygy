# == Schema Information
#
# Table name: purchases
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  amount     :string(255)
#  created_at :datetime
#  updated_at :datetime
#  game_id    :integer
#

class Purchase < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

end
