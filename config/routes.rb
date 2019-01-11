Rails.application.routes.draw do
  root to: 'home#show'

  get  'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get  'registration', to: 'registration#new'
  post 'registration', to: 'registration#create'
  get  'registration/activate', to: 'registration#activate'

  get  'reset_password', to: 'password_reset#new', as: :new_reset_password
  post 'reset_password', to: 'password_reset#create', as: :reset_password
  get  'reset_password/:id', to: 'password_reset#edit', as: :new_reset_password_tokenized
  match 'reset_password/:id', to: 'password_reset#update', as: :reset_password_tokenized, via: [:put, :patch]

  namespace :admin do
    resource :dashboard, only: [:show], controller: :dashboard
  end

  resource :home, only: [:show], controller: :home

  resource :dashboard, only: [:show], controller: :dashboard
  resource :profile, only: [:edit, :update], controller: :profile

  if Rails.env.development?
    require 'sidekiq/web'
    require 'sidekiq/cron/web'

    mount Sidekiq::Web, at: '/sidekiq'
  end
end
