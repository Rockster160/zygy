# == Schema Information
#
# Table name: user_games
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  game_id    :integer
#  username   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class UserGame < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  has_many :user_game_scores
  has_many :user_score_trackers
  has_many :security_keys
  has_many :purchases
  has_many :purchase_trackers

  def scores; user_game_scores; end

  def high_score
    scores.order(score: :desc).first.try(:score) || 0
  end
  def purchases_total
    purchases.inject(0) { |sum, purchase| sum + purchase.amount }
  end

  def generate_authorization_code
    key = security_keys.first_or_create
    key.generate_new_key
  end

end
