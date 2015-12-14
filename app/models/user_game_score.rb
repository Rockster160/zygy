# == Schema Information
#
# Table name: user_game_scores
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  game_id    :integer
#  score      :integer
#  created_at :datetime
#  updated_at :datetime
#

class UserGameScore < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  after_create :set_defaults

  def set_defaults
    self.score ||= 0
    self.save
  end
  
end
