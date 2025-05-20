# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  mount Sidekiq::Web => '/sidekiq'

  mount PublicApi::Root => '/public_api'

  get 'up', to: 'rails/health#show', as: :rails_health_check

  get  'signup', to: 'signup#new'
  post 'signup', to: 'signup#create'
  get  'signup/success', to: 'signup#success', as: 'success_signup'
  get  'signup/activate/:token', to: 'signup#activate', as: 'activate_signup'
  match 'signup/request_activation_link', to: 'signup#request_activation_link', as: 'request_activation_link_signup',
        via: %i[get post]

  get    'sign_in', to: 'sign_in#new'
  post   'sign_in', to: 'sign_in#create'
  delete 'sign_in', to: 'sign_in#destroy'

  get  'password_reset', to: 'password_reset#new'
  post 'password_reset', to: 'password_reset#create'
  get  'password_reset/success', to: 'password_reset#success', as: 'success_password_reset'
  get  'password_reset/:token', to: 'password_reset#edit', as: 'new_password_password_reset'
  put  'password_reset/:token', to: 'password_reset#update', as: 'set_new_password_password_reset'

  resource :dashboard, only: %i[show], controller: 'dashboard'
  resource :profile, only: %i[show update], controller: 'profile'
  resources :documents, only: %i[index create destroy] do
    collection do
      match 's3/params', to: 'documents#s3_params', via: %i[get]
    end

    member do
      get :download
    end
  end
  get 'chat/(:room)', to: 'chat#show', as: 'chat'

  get 'too_many_requests', to: 'pages#too_many_requests'
  get 'swagger', to: 'pages#swagger'

  get 'about', to: 'home#about'

  namespace :admin do
    get    'sign_in', to: 'sign_in#new'
    post   'sign_in', to: 'sign_in#create'
    delete 'sign_in', to: 'sign_in#destroy'

    resource :dashboard, only: %i[show], controller: 'dashboard'
    resources :users, only: %i[index] do
      collection do
        post :request_user_stats
      end
    end
    resources :api_tokens, only: %i[index create destroy]
  end

  get 'admin', to: redirect('/admin/dashboard')

  root 'home#show'
end
