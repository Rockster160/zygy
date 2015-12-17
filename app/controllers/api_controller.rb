class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def verify_login_information
    user = nil
    game_code = request.headers['Game-Identifier']
    auth_code = request.headers['Authorization-Code']

    if params[:identifier_field].present? && params[:password].present?
      temp_user = User.where('email=? OR solution_number=?', params[:identifier_field], params[:identifier_field].upcase).first
      if temp_user
        user = temp_user.valid_password?(params[:password]) ? temp_user : nil
      end
    elsif auth_code.present?
      user = user_from_game_authorization(game_code, auth_code)
    end

    if user.present? && game_code.present?
      response.headers["Authorization-Success"] = 'true'
      response.headers["Authorization-Code"] = user.generate_authorization_for_game_code(game_code)
    else
      response.headers["Authorization-Success"] = 'false'
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def register_new_user
    server_error = ''
    unless params[:passwordField] == params[:passwordConfirmationField]
      server_error = 'Server: Passwords must match.'
    end
    upline = User.where(solution_number: params[:referralIdField].upcase).first
    if upline
      user = upline.downlines.new(
        first_name: params[:firstNameField],
        last_name: params[:lastNameField],
        email: params[:emailField],
        password: params[:passwordField]
      )
      unless user.save
        server_error = user.errors.full_messages.first
      end
    else
      server_error = "Invalid Referral Code"
    end
    if server_error.length == 0
      response.headers['Authorization-Success'] = 'true'
      response.headers['Solution-Number'] = user.solution_number
      response.headers["Authorization-Code"] = user.generate_authorization_for_game_code(request.headers['Game-Identifier'])
    else
      response.headers['Authorization-Success'] = 'false'
      response.headers['Error-Message'] = server_error
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
      response.headers['Authorization-Success'] = 'true'
      response.headers["Authorization-Code"] = user.generate_authorization_for_game_code(game_code)
      user.new_score_for_game_code(params[:username], game_code, params[:score].to_i)
    else
      response.headers['Authorization-Success'] = 'false'
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def user_from_game_authorization(game_identifier, authorization)
    key = SecurityKey.where(game_id: Game.by_code(game_identifier).id, authorization_code: authorization).first
    return nil unless key
    key.user
  end

end
