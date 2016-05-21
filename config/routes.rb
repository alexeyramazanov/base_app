Rails.application.routes.draw do
  root to: 'home#show'

  get  'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  get  'registration' => 'registration#new'
  post 'registration' => 'registration#create'
  get  'registration/activate' => 'registration#activate'

  get  'reset_password' => 'password_reset#new', as: :new_reset_password
  post 'reset_password' => 'password_reset#create', as: :reset_password
  get  'reset_password/:id' => 'password_reset#edit', as: :new_reset_password_tokenized
  match 'reset_password/:id' => 'password_reset#update', as: :reset_password_tokenized, via: [:put, :patch]

  resource :home, only: [:show], controller: :home

  resource :dashboard, only: [:show], controller: :dashboard

  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
