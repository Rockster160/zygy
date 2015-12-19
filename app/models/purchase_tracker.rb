# == Schema Information
#
# Table name: purchase_trackers
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  game_id    :integer
#  at_1       :integer          default(0)
#  at_2       :integer          default(0)
#  at_3       :integer          default(0)
#  at_4       :integer          default(0)
#  at_5       :integer          default(0)
#  at_6       :integer          default(0)
#  at_7       :integer          default(0)
#  at_8       :integer          default(0)
#  at_9       :integer          default(0)
#  at_10      :integer          default(0)
#  at_11      :integer          default(0)
#  at_12      :integer          default(0)
#  at_13      :integer          default(0)
#  at_14      :integer          default(0)
#  at_15      :integer          default(0)
#  cumulative :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class PurchaseTracker < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  def at_0; cumulative; end
  def at(x)
    return cumulative if x == 0
    method("at_#{x}".to_sym).call
  end

  def thru(x)
    x = x.to_i
    cumulative + x.times.map { |t| at(t+1) }.inject(0) { |sum, v| sum + v }
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

  def recalculate_cumulative
    new_cumulative = user.purchases_for_game_id(game.id).map(&:amount).inject(0) { |sum, amount| sum + amount }
    unless did_match = scores_match?(cumulative, new_cumulative)
      update(cumulative: new_cumulative)
    end
    did_match
  end

  def recalculate_at(x)
    purchases = user.downlines_by(x).map { |dl| dl.purchase_total_for_game_id(game.id) }
    cumulative_at_x = purchases.inject(0) { |sum, total_value| sum + total_value }
    unless did_match = scores_match?(at(x), cumulative_at_x)
      update("at_#{x}".to_sym => cumulative_at_x)
    end
    did_match
  end

  def refresh
    all_passed = true
    all_passed = false unless recalculate_cumulative

    15.times do |t|
      all_passed = false unless recalculate_at(t + 1)
    end
    all_passed
  end

end
