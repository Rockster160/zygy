Rails.application.routes.draw do

  root 'admin#root'
  get 'user_tree' => 'admin#user', as: 'user'
  get 'users.json' => 'admin#users_json', as: 'users_json'

  post '/api/sign_in' => 'api#verify_login_information'
  post '/api/register' => 'api#register_new_user'
  post '/api/new_score' => 'api#new_score'
  post '/api/new_purchase' => 'api#new_purchase'

  get 'filtered_users' => 'admin#filtered_users_table'

  devise_for :users

end
