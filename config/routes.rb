Rails.application.routes.draw do
  
  root 'admin#root'

  devise_for :users

end
