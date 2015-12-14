# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  solution_number        :string(255)
#  upline_id              :integer
#  first_name             :string(255)
#  last_name              :string(255)
#

# avatar
# access_level => enum (standard mod admin)
# life_cash_accumulated   \_- Do we need these? How else should it be tracked?
# non_paid_out_cash       /
# hierarchy_level => enum (Representative Sr.Representative District Division Regional Sr.Regional RVP SVP NSD SNSD)
# Baseshop: All non-RVPs below you not under another RVP

# Track only high scores or accumulated scores?

# Payout - Evenly among 8 upper Qualified reps
# If not enough qualified, remainder goes straight to Zygy
# Non-registered user purchases goes straight to Zygy
# Cannot Change uplines ***

# class Purchase
# purchased_by, date/time, amount_of_purchase

class User < ActiveRecord::Base
  QUALIFIED_BENCHMARK = 100
  PAYOUT_PERCENTAGE = [3]*8 # *8 means split equally 8 times

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :upline, class_name: 'User'
  has_many :downlines, class_name: 'User', foreign_key: 'upline_id'
  has_many :user_game_scores
  has_many :security_keys

  def scores; user_game_scores; end

  scope :by_scores_for_game, lambda { |game_id| joins(:user_game_scores).where(user_game_scores: { game_id: 1234 }).order("user_game_scores.score desc") }

  after_create :set_solution_number

  def new_score_for_game(game_identifier, score)
    game = Game.by_identifier(game_identifier)
    return false unless game
    scores.where(game_id: game.id).first_or_create.try_update_score(score)
    # FIXME - Should this always create a new score?
  end

  def generate_authorization_code_for_game(game_identifier)
    game = Game.by_identifier(game_identifier)
    return false unless game
    key = security_keys.where(game_id: game.id).first_or_create
    key.generate_new_key
  end

  def score_for_game(game_id)
    scores.find_by_game_id(game_id).try(:score) || 0
  end

  def scores_at_level_for_game(x, game_id)
    downlines_by(x).inject(0) { |sum, user| sum + user.score_for_game(game_id) }
  end

  def scores_thru_level_for_game(x, game_id)
    return self.score_for_game(game_id) if x == 0
    self.score_for_game(game_id) + all_downlines_by(x).inject(0) { |sum, user| sum + user.score_for_game(game_id) }
  end

  def address(string_format='%s1 %s2 %c, %S, %z %C')
    string_format.gsub!('%s1', street1)
    string_format.gsub!('%s2', street2)
    string_format.gsub!('%c', city)
    string_format.gsub!('%S', state)
    string_format.gsub!('%z', zip)
    string_format.gsub!('%C', country)
  end

  def self.solution_to_integer(sol)
    sol.upcase!
    characters = (('0'..'9').to_a + ('A'..'Z').to_a)
    mapped = sol.split('').map { |char| characters.find_index { |e| e.match( char ) } }
    mapped.reverse.each_with_index.map do |val, ind|
      (characters.count ** ind) * val
    end.inject(&:+)
  end

  def self.topline
    where(upline_id: nil)
  end

  #  return user that is x levels uplined
  def upline_by(x)
    return self if x == 0
    x = x.to_i
    return nil unless x > 0
    u = self.upline
    (x - 1).times { u.nil? ? nil : u = u.upline }.compact
    return u
  end
  # return array of users up to x levels up
  def uplines_by(x)
    return [self] if x == 0
    x = x.to_i
    return [] unless x > 0
    u = self
    x.times.map { u.nil? ? nil : u = u.upline }.compact.reverse
  end
  # return array of all uplines until max
  def all_uplines
    uplines = []
    next_upline = upline
    until next_upline.nil?
      uplines << next_upline
      next_upline = next_upline.upline
    end
    uplines
  end

  # return array of all downlines to lowest level
  def all_downlines
    return_downlines = []
    next_downlines = downlines
    until next_downlines.empty?
      return_downlines += next_downlines
      next_downlines = next_downlines.map(&:downlines).flatten
    end
    return_downlines
  end
  # return array of users down every level until x levels
  def all_downlines_by(x)
    return [self] if x == 0
    x = x.to_i
    return [] unless x > 0
    current_downlines = self.downlines
    current_downlines + (x - 1).times.map do
      current_downlines = current_downlines.map do |user|
        user.downlines
      end.flatten
    end.flatten
  end
  # return array of users x levels down
  def downlines_by(x)
    return [self] if x == 0
    x = x.to_i
    return [] unless x > 0
    current_downlines = self.downlines
    (x - 1).times do
      current_downlines = current_downlines.map do |user|
        user.downlines
      end.flatten
    end
    current_downlines
  end

  private

  def set_solution_number
    self.update(solution_number: id.to_s(36).upcase.rjust(6, '0'))
  end

end
