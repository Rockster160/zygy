# == Schema Information
#
# Table name: purchases
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  game_id    :integer
#  amount     :integer          default(0)
#

class Purchase < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  after_create :update_trackers

  # Purchases always calculate cumulative - they don't worry about highs
  def update_trackers
    tracker = user.purchase_trackers.where(game_id: game_id).first_or_create
    new_cumulative = tracker.cumulative + amount
    # TODO Add any other trackers here
    tracker.update(cumulative: new_cumulative)
    c_user = user
    15.times do |t|
      next unless c_user && c_user = c_user.upline
      current_at = "at_#{t + 1}".to_sym

      tracker = c_user.purchase_trackers.where(game_id: game_id).first_or_create
      old_total = tracker.method(current_at).call
      new_total = old_total + amount
      tracker.update(current_at => new_total)
    end
  end

end
