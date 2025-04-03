# frozen_string_literal: true

Rails.application.routes.draw do
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

  get 'too_many_requests', to: 'pages#too_many_requests'

  get 'about', to: 'home#about'

  root 'home#show'
end
