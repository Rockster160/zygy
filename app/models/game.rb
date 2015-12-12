# == Schema Information
#
# Table name: games
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  game_identifier :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Game < ActiveRecord::Base

  def self.by_identifier(identifier)
    find_by_game_identifier(identifier)
  end

  after_create :create_identifier
  validates :game_identifier, uniqueness: true

  def create_identifier
    return unless game_identifier.nil?
    return if name.nil?
    identifier = name.split('').map do |char|
      case char
      when '-' then ' '
      when '27' then "'"
      else char.downcase.ord - 'a'.ord + 1
      end
    end.join
    update(game_identifier: identifier)
    game_identifier
  end

end
