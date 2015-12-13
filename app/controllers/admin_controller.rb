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
          solution_number: user.solution_number,
          score: score,
          uplines_solution: user.upline.try(:solution_number)
        }
      end
    end.compact.sort_by { |u| u[:score] }.reverse.first(50)

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def verify_login_information
    user = nil
    game_code = request.headers['Game-Identifier']
    auth_code = request.headers['Authorization-Code']

    if params[:identifier_field].present? && params[:password].present?
      temp_user = User.where('email=? OR solution_number=?', params[:identifier_field], params[:identifier_field]).first
      if temp_user
        user = temp_user.valid_password?(params[:password]) ? temp_user : nil
      end
    elsif auth_code.present?
      user = user_from_game_authorization(game_code, auth_code)
    end

    if user.present? && game_code.present?
      response.headers["Authorization-Success"] = 'true'
      response.headers["Authorization-Code"] = user.generate_authorization_code_for_game(game_code)
    else
      response.headers["Authorization-Success"] = 'false'
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def new_score
    game_code = request.headers['Game-Identifier']
    auth_code = request.headers['Authorization-Code']
    user = user_from_game_authorization(game_code, auth_code)

    if user.present?
      puts "\e[32mSuccess\e[0m"
      response.headers['Authorization-Success'] = 'true'
      response.headers["Authorization-Code"] = user.generate_authorization_code_for_game(game_code)
      user.new_score_for_game(game_code, params[:score].to_i)
    else
      puts "\e[31mFailure\e[0m"
      response.headers['Authorization-Success'] = 'false'
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # puts "\e[32m#{}\e[0m"

  def level_to_int(level)
    %w[Personal 1st 2nd 3rd 4th 5th 6th].indexOf(level)
  end

  def user_from_game_authorization(game_identifier, authorization)
    key = SecurityKey.where(game_id: Game.by_identifier(game_identifier).id, authorization_code: authorization).first
    # puts "\e[32m#{authorization}\e[0m"
    # puts "\e[32m#{key}\e[0m"
    return nil unless key
    key.user
  end

end
