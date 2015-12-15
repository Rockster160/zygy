Rails.application.routes.draw do

  root 'admin#root'
  get 'user_tree' => 'admin#user', as: 'user'

  post '/api/sign_in' => 'api#verify_login_information'
  post '/api/register' => 'api#register_new_user'
  post '/api/new_score' => 'api#new_score'

  get 'filtered_users' => 'admin#filtered_users_table'

  devise_for :users

end
