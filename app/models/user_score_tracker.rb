# == Schema Information
#
# Table name: user_score_trackers
#
#  id            :integer          not null, primary key
#  at_1          :integer          default(0)
#  at_2          :integer          default(0)
#  at_3          :integer          default(0)
#  at_4          :integer          default(0)
#  at_5          :integer          default(0)
#  at_6          :integer          default(0)
#  at_7          :integer          default(0)
#  at_8          :integer          default(0)
#  at_9          :integer          default(0)
#  at_10         :integer          default(0)
#  at_11         :integer          default(0)
#  at_12         :integer          default(0)
#  at_13         :integer          default(0)
#  at_14         :integer          default(0)
#  at_15         :integer          default(0)
#  all_time_high :integer          default(0)
#  cumulative    :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  user_game_id  :integer
#  game_id       :integer
#  user_id       :integer
#

class UserScoreTracker < ActiveRecord::Base

  belongs_to :user_game

  after_create :add_game_and_user_id

  def add_game_and_user_id
    self.game_id = user_game.game.id
    self.user_id = user_game.user.id
    self.save
  end

  def at_0; all_time_high; end
  def at(x)
    return all_time_high if x == 0
    method("at_#{x}".to_sym).call
  end

  def thru(x)
    x = x.to_i
    all_time_high + x.times.map { |t| at(t+1) }.inject(0) { |sum, v| sum + v }
  end

  def scores_match?(a, b)
    if a == b
      puts "#{a} == #{b}".colorize(:green)
      return true
    else
      puts "IS NOT THE SAME!!!! : #{a} != #{b}".colorize(:red)
      return false
    end
  end

  def recalculate_high
    high = user_game.high_score
    unless did_match = scores_match?(high, all_time_high)
      update(all_time_high: high)
    end
    did_match
  end

  def recalculate_cumulative
    new_cumulative = user_game.scores.map(&:score).inject(0) { |sum, score| sum + score }
    unless did_match = scores_match?(cumulative, new_cumulative)
      update(cumulative: new_cumulative)
    end
    did_match
  end

  def recalculate_at(x)
    high_scores = user_game.user.downlines_by(x).map { |dl| dl.game(user_game.game.id).high_score }
    highest_score = high_scores.inject(0) { |sum, score| sum + score }
    unless did_match = scores_match?(at(x), highest_score)
      update("at_#{x}".to_sym => highest_score)
    end
    did_match
  end

  def refresh
    all_passed = true
    all_passed = false unless recalculate_high
    all_passed = false unless recalculate_cumulative

    15.times do |t|
      all_passed = false unless recalculate_at(t + 1)
    end
    all_passed
  end

end
