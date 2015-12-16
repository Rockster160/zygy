class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token

  def filtered_users_table
    @game = Game.find(params[:game])
    @base_level = params[:base_level].to_i

    main_value = params[:depth] == "at" ? (@base_level == 0 ? "all_time_high" : "at_#{@base_level}") : "(all_time_high + #{([0] + @base_level.times.map {|t| "at_#{t+1}"}).join(" + ")})"
    @filtered_trackers = UserScoreTracker
      .limit(50)
      .where(game_id: @game.id)
      .where("#{main_value} > 0")
      .order("#{main_value} desc")

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def user
    # Create JSON object for Upline, User, and downlines, branching.
  end

end
