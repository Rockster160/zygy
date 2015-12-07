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
#

class User < ActiveRecord::Base
  belongs_to :upline, class_name: 'User'
  has_many :downlines, class_name: 'User', foreign_key: 'upline_id'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :set_solution_number

  # def solution_to_integer(sol)
  #   characters = (('0'..'9').to_a + ('A'..'Z').to_a)
  #   mapped = sol.split('').map { |char| characters.find_index { |e| e.match( char ) } }
  #   mapped.reverse.each_with_index.map do |val, ind|
  #     (characters.count ** ind) * val
  #   end.inject(&:+)
  # end

  def self.topline
    where(upline_id: nil)
  end

  #  return user that is x levels uplined
  def upline_by(x)
    x = x.to_i
    return nil unless x > 0
    u = self.upline
    (x - 1).times { u.nil? ? nil : u = u.upline }.compact
    return u
  end
  # return array of users up to x levels up
  def uplines_by(x)
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
    self.update(solution_number: id.to_s(36).upcase.rjust(5, '0'))
  end

end
