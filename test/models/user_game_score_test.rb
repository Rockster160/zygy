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

require 'test_helper'

class UserGameScoreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
