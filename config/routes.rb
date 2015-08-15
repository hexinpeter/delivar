Rails.application.routes.draw do
  root to: 'users#index'
  get 'users/account' => 'users#account'
  devise_for :users
  resources :users

  resources :orders
end
