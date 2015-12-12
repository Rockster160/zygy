class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token

  def verify_login_information
    user = User.where('email=? OR solution_number=?', params[:identifier_field], params[:identifier_field]).first
    game_code = request.headers['Game-Identifier']

    response.headers["Login-Success"] = (user && user.valid_password?(params[:password])).to_s
    if user && game_code
      response.headers["Authorization-Code"] = user.generate_authorization_code_for_game(game_code)
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def new_score
    game_identifier = params[:game]
    auth_code = request.headers['Authorization-Code']
    key = SecurityKey.where(game_id: Game.by_identifier(game_identifier).id)
    if response.headers['Authorization-Success'] = (key.valid_authorization_code(auth_code) && key.user)
      key.user.new_score_for_game(params[:game], params[:score].to_i)
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
