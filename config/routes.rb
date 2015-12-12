Rails.application.routes.draw do

  root 'admin#root'

  post '/api/sign_in' => 'admin#verify_login_information'
  post '/api/:game/new_score' => 'admin#new_score'

  devise_for :users

end
