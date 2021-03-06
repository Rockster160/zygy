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

  has_many :user_games

  after_create :create_identifier

  validates :game_identifier, uniqueness: true

  def user(user_id)
    user_games.where(user_id: user_id).first_or_create
  end

  def code; game_identifier; end

  def self.by_code(code)
    return nil unless code
    self.find_by_game_identifier(code.to_s)
  end

  def self.show_all
    puts Game.all.map {|game| "#{game.name} : #{game.game_identifier}"}
  end

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
