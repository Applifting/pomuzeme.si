Rails.application.routes.draw do
  # Redirect from faulty link to the actual document
  get '/ochrana-osobnich-udaju.pdf', to: redirect { 'podminky_ochrany_osobnich_udaju_pomuzemesi.pdf' }

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :home, only: :index do
    post :test_post, on: :collection
    post :test_set, on: :collection
  end

  get 'prihlaseni', to: 'sessions#new', as: :login
  post 'overeni', to: 'sessions#request_code', as: :request_code
  get 'overeni', to: 'sessions#new'
  post 'verify_code', to: 'sessions#verify_code', as: :verify_code
  get 'logout', to: 'sessions#logout'
  get 'profil', to: 'volunteer_profiles#show', as: :profile

  resource :volunteer, only: [] do
    post :register, on: :collection
    post :confirm, on: :collection
    post :resend, on: :collection
  end

  namespace :api do
    namespace :v1 do
      post '/geo/fulltext', to: 'geolocation#fulltext'
      post '/session/new', to: 'session#new'
      post '/session/create', to: 'session#create'
      post '/session/refresh', to: 'session#refresh'
      namespace :organisations do
        get '/', action: :index
      end
      namespace :volunteer do
        get 'organisations'
        get 'profile'
        put 'profile', action: :update_profile
        put 'register'
        get 'preferences'
        put 'preferences', action: :update_preferences
        namespace :requests do
          get '/', action: :index
          post '/:id/respond', action: :respond
        end
        resources :addresses, except: %i[edit new]
      end
    end
  end

  root 'home#index'
  get '/:slug', param: :slug, to: 'home#partner_signup', slug: /(?!.*?admin).*/

  namespace :docs do
    get '/partner-kit', to: redirect { 'https://drive.google.com/drive/folders/1w9_PVRbZ9VvE10zY0sR26f6SlmLq0xZn' }
    get '/letak-linky-pomoci', to: redirect { 'https://d113nbfwgx4fgo.cloudfront.net/leaflet-diakonie.pdf' }
  end
end
