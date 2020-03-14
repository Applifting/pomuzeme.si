Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html


  resources :home, only: :index
  root 'home#index'

  post '/api/sms_callback', to: 'callback#sms'

end
