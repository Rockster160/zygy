Rails.application.routes.draw do

  root 'admin#root'

  post '/sign_in' => 'admin#sign_in'

  devise_for :users

end
