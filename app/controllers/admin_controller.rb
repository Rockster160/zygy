class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token

  def filtered_users_table
    @game = Game.find(params[:game])
    @base_level = params[:base_level].to_i

    if params[:depth] == "at"
      main_value = @base_level == 0 ? "all_time_high" : "at_#{@base_level}"
    else
      main_value = "(all_time_high + #{([0] + @base_level.times.map {|t| "at_#{t+1}"}).join(" + ")})"
    end

    @filtered_trackers = UserScoreTracker
      .limit(50)
      .where(game_id: @game.id)
      .where("#{main_value} > 0")
      .order("#{main_value} desc")

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def users_json
    @game = Game.find(params[:game_id])
    @user = User.find(params[:user_id])
    layers = params[:layer_count]
    @users_json = {
      upline: get_user_hash(@user.upline),
      user: get_user_hash(@user).merge(recursive_downlines(@user, 4))
    }
    respond_to do |format|
      format.json { render json: @users_json }
    end
  end

  private

  def get_user_hash(user)
    return {} unless user
    score = user.high_score_for_game_id(@game.id)
    {
      name: "#{user.first_name} #{user.last_name} - #{user.solution_number}",
      username: "#{user.username_for_game(@game).presence || 'No Username'}",
      personal: score == 0 ? "Never Played" : score,
      user_id: user.id,
      directs_count: user.downlines.count
    }
  end

  def recursive_downlines(user, layers)
    return {} if user.nil? || layers == 0
    downlines = user.downlines.sort { |u| u.high_score_for_game_id(@game.id) }.last(3)
    {
      downlines: downlines.map do |downline|
        get_user_hash(downline).merge(recursive_downlines(downline, layers-1))
      end
    }
  end

end
