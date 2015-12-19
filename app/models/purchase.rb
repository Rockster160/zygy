# == Schema Information
#
# Table name: purchases
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  amount       :integer          default(0)
#  user_game_id :integer
#

class Purchase < ActiveRecord::Base

  belongs_to :user_game

  after_create :update_trackers

  # Purchases always calculate cumulative - they don't worry about highs
  def update_trackers
    tracker = user_game.purchase_trackers.first || user_game.purchase_trackers.create
    new_cumulative = tracker.cumulative + amount
    # TODO Add any other trackers here
    tracker.update(cumulative: new_cumulative)
    current_user_game = user_game
    15.times do |t|
      next unless current_user_game && upline = current_user_game.user.upline
      current_user_game = upline.game(user_game.game.id)
      current_at = "at_#{t + 1}".to_sym

      tracker = current_user_game.purchase_trackers.first || current_user_game.purchase_trackers.create
      old_total = tracker.method(current_at).call
      new_total = old_total + amount
      tracker.update(current_at => new_total)
    end
  end

end
