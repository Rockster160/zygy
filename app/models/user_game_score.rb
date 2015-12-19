# == Schema Information
#
# Table name: user_game_scores
#
#  id           :integer          not null, primary key
#  score        :integer
#  created_at   :datetime
#  updated_at   :datetime
#  username     :string(255)
#  level        :integer
#  user_game_id :integer
#

class UserGameScore < ActiveRecord::Base

  belongs_to :user_game

  after_create :set_defaults
  after_create :update_trackers

  def update_trackers
    tracker = user_game.user_score_trackers.first || user_game.user_score_trackers.create
    new_cumulative = tracker.cumulative + score
    old_high = tracker.all_time_high
    difference_in_scores = score > old_high ? (score - old_high) : 0
    new_high = score > old_high ? score : old_high
    # TODO Add any other trackers here
    tracker.update(cumulative: new_cumulative, all_time_high: new_high)
    current_user_game = user_game
    15.times do |t|
      next unless current_user_game && upline = current_user_game.user.upline
      current_user_game = upline.game(user_game.game.id)
      current_at = "at_#{t + 1}".to_sym

      tracker = current_user_game.user_score_trackers.first || current_user_game.user_score_trackers.create
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
