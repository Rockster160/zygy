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
#  username   :string(255)
#

class UserGameScore < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  after_create :set_defaults
  after_create :update_trackers

  def update_trackers
    tracker = user.user_score_trackers.where(game_id: game_id).first_or_create
    new_cumulative = tracker.cumulative + score
    old_high = tracker.all_time_high
    difference_in_scores = score > old_high ? (score - old_high) : 0
    new_high = score > old_high ? score : old_high
    # TODO Add any other trackers here
    tracker.update(cumulative: new_cumulative, all_time_high: new_high)
    c_user = user
    15.times do |t|
      next unless c_user && c_user = c_user.upline
      current_at = "at_#{t + 1}".to_sym

      tracker = c_user.user_score_trackers.where(game_id: game_id).first_or_create
      score = tracker.method(current_at).call
      new_score = score + difference_in_scores
      tracker.update(current_at => new_score)
    end
  end

  def set_defaults
    self.score ||= 0
    self.save
  end

end
