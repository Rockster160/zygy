# == Schema Information
#
# Table name: user_score_trackers
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  game_id       :integer
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
#

class UserScoreTracker < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

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
      puts "IS NOT THE SAME!!!! - #{a} != #{b}".colorize(:red)
      return false
    end
  end

  def recalculate_high
    high = user.high_score_for_game_id(game.id)
    puts "recalculate_high"
    unless scores_match?(high, all_time_high)
      update(all_time_high: high)
    end
  end

  def recalculate_cumulative
    my_scores = user.scores_for_game_id(game.id)
    downline_scores = user.all_downlines.map { |downline| downline.scores_for_game_id(game.id) }
    new_cumulative = (my_scores + downline_scores).flatten.map(&:score).inject(0) { |sum, score| sum + score }
    puts "recalculate_cumulative"
    unless scores_match?(cumulative, new_cumulative)
      update(cumulative: new_cumulative)
    end
  end

  def recalculate_at(x)
    high_scores = user.downlines_by(x).map { |dl| dl.high_score_for_game_id(game.id) }
    highest_score = high_scores.sort.last || 0
    puts "recalculate_at - #{x}"
    unless scores_match?(at(x), highest_score)
      update("at_#{x}".to_sym => highest_score)
    end
  end
# These may not work as expected...
  def refresh
    recalculate_high
    recalculate_cumulative

    15.times do |t|
      recalculate_at(t + 1)
    end
  end

end
