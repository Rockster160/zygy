class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token

  def sign_in
    puts "\e[33m#{params}\e[0m"
    user = User.where('email=? OR solution_number=?', params[:identifier_field], params[:identifier_field]).first

    response.headers["Login-Success"] = (user && user.valid_password?(params[:password])).to_s
    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
