Rails.application.routes.draw do

  root 'admin#root'

  post '/api/sign_in' => 'admin#verify_login_information'
  post '/api/new_score' => 'admin#new_score'

  get 'filtered_users' => 'admin#filtered_users_table'

  devise_for :users

end
