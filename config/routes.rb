Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'home#index', as: :home_page
  # Redirect from faulty link to the actual document
  get '/ochrana-osobnich-udaju.pdf', to: redirect { 'podminky_ochrany_osobnich_udaju_pomuzemesi.pdf' }

  resources :home, only: :index do
    post :test_post, on: :collection
    post :test_set, on: :collection
  end

  get 'prihlaseni', to: 'sessions#new', as: :login
  post 'overeni', to: 'sessions#request_code', as: :request_code
  get 'overeni', to: 'sessions#new'
  post 'verify_code', to: 'sessions#verify_code', as: :verify_code
  get 'logout', to: 'sessions#logout'
  get 'profil', to: 'volunteer_profiles#show', as: :volunteer_profile
  patch 'update_volunteer_profile', to: 'volunteer_profiles#update', as: :update_volunteer_profile
  get 'zruseni_profilu', to: 'volunteer_profiles#confirm_destroy', as: :confirm_destruction_of_volunteer_profile
  post 'close_account', to: 'volunteer_profiles#destroy', as: :destroy_volunteer_profile
  get 'profil_zrusen', to: 'volunteer_profiles#destroyed', as: :profile_destroyed

  get 'prilezitosti', to: 'requests#index', as: :requests
  get 'accept', to: 'requests#accept', as: :accept_request
  get 'zadost-prijata', to: 'requests#request_accepted', as: :request_accepted
  get 'potvrdte-zajem/:request_id', to: 'requests#confirm_interest', as: :confirm_interest
  get 'potrebuji-dobrovolniky', to: 'requests#need_volunteers', as: :need_volunteers
  get 'zadost-o-dobrovolniky', to: 'requests#new', as: :new_request
  post 'zadost-o-dobrovolniky', to: 'requests#create', as: :request
  get 'zadost-o-dobrovolniky-prijata', to: 'requests#new_request_accepted', as: :new_request_accepted

  resource :volunteer, only: [] do
    post :register, on: :collection
    post :confirm, on: :collection
    post :resend, on: :collection
  end

  resource :location_subscription, only: [:create]

  post 'overeni-upozorneni-na-nove-zadosti', to: 'location_subscriptions#request_code', as: :location_subscription_request_code

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
  post '/api/sms_callback', to: 'callback#sms'

  namespace :docs do
    get '/partner-kit', to: redirect { 'https://drive.google.com/drive/folders/1w9_PVRbZ9VvE10zY0sR26f6SlmLq0xZn' }
    get '/letak-linky-pomoci', to: redirect { 'https://d113nbfwgx4fgo.cloudfront.net/leaflet-diakonie.pdf' }
  end

  get '/:slug', param: :slug, to: 'home#partner_signup', slug: /(?!.*?admin).*/
end
