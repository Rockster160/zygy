class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def verify_login_information
    user = nil
    game_code = request.headers['Game-Identifier']
    game = Game.by_code(game_code)
    auth_code = request.headers['Authorization-Code']

    if params[:identifier_field].present? && params[:password_field].present?
      temp_user = User.where('email=? OR zygy_id=?', params[:identifier_field], params[:identifier_field].upcase).first
      unless temp_user
        ug = UserGame.where("lower(username) = ?", params[:identifier_field].downcase).first
        temp_user = ug ? ug.user : nil
      end
      if temp_user
        user = temp_user.valid_password?(params[:password_field]) ? temp_user.game(game.id) : nil
      end
    elsif auth_code.present?
      user = user_from_game_authorization(game_code, auth_code)
    end

    if user.present? && game_code.present?
      response.headers["Authorization-Success"] = 'true'
      response.headers["Authorization-Code"] = user.generate_authorization_code
    else
      response.headers["Authorization-Success"] = 'false'
      error = user.present? ? 'An unknown error occurred.' : "Invalid Username or Password."
      response.headers['Error-Message'] = error
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def register_new_user
    server_error = ''
    game = Game.by_code(request.headers['Game-Identifier'])
    unless params[:passwordField] == params[:passwordConfirmationField]
      server_error = 'Server: Passwords must match.'
    end
    upline = User.where(zygy_id: params[:referralIdField].upcase).first if params[:referralIdField].present?

    if upline && params_all_present?
      user = upline.downlines.new(
        first_name: params[:firstNameField],
        last_name: params[:lastNameField],
        email: params[:emailField],
        password: params[:passwordField]
      )
      ug = UserGame.where(game_id: game.id).new(username: params[:usernameField])
      if ug.valid?
        ug.destroy
        if user.save
          user.game(game.id).update(username: params[:usernameField])
        else
          server_error = user.errors.full_messages.first
        end
      else
        server_error = ug.errors.first.try(:last) || "Username has already been taken"
      end
    else
      server_error = params_all_present? ? "Invalid Referral Code" : "All fields are required."
    end
    if server_error.length == 0
      response.headers['Authorization-Success'] = 'true'
      response.headers['Zygy-ID'] = user.zygy_id
      response.headers["Authorization-Code"] = user.game(game.id).generate_authorization_code
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
      response.headers["Authorization-Code"] = user.generate_authorization_code
      user.scores.create(score: params[:score].to_i, level: params[:level])
    else
      response.headers['Authorization-Success'] = 'false'
      response.headers['Error-Message'] = "Authorization Failure"
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def new_purchase
    game_code = request.headers['Game-Identifier']
    auth_code = request.headers['Authorization-Code']
    user = user_from_game_authorization(game_code, auth_code)

    if user.present?
      response.headers['Authorization-Success'] = 'true'
      response.headers["Authorization-Code"] = user.generate_authorization_code
      user.purchases.create(amount: params[:purchase_price].to_i.round)
    else
      response.headers['Authorization-Success'] = 'false'
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def user_from_game_authorization(game_identifier, authorization)
    key = SecurityKey.joins(:user_game).where(
      user_games: { game_id: Game.by_code(game_identifier).id }
    ).where(authorization_code: authorization).first
    return nil unless key
    key.user_game
  end

  def params_all_present?
    params[:usernameField].present? &&
    params[:referralIdField].present?
    params[:firstNameField].present? &&
    params[:lastNameField].present? &&
    params[:emailField].present? &&
    params[:passwordField].present? &&
    params[:passwordConfirmationField].present?
  end

end
