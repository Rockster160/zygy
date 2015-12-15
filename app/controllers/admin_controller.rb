class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token

  def filtered_users_table
    game = Game.find(params[:game])
    @filtered_users = User.all.map do |user|
      score = case params[:depth]
      when "at" then user.scores_at_level_for_game(params[:base_level].to_i, game.id)
      when "thru" then user.scores_thru_level_for_game(params[:base_level].to_i, game.id)
      else "\e[31m#{params[:depth]}\e[0m"
      end
      if score > 0
        {
          user_route: user_url(user),
          solution_number: user.solution_number,
          personal_score: user.high_score_for_game(game.id),
          score: score,
          upline_route: user.upline ? user_url(user.upline) : nil,
          uplines_solution: user.upline.try(:solution_number)
        }
      end
    end.compact.sort_by { |u| u[:score] }.reverse.first(50)

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def user
    # Create JSON object for Upline, User, and downlines, branching.
  end

end
