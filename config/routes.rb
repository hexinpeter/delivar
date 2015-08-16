Rails.application.routes.draw do
  root to: 'users#index'
  devise_for :users
  get 'users/account' => 'users#account'
  get 'users/index', to: 'users#index'
  get 'users/show', to: 'users#show'
  get 'users/deliveries', to: 'users#deliveries', as: 'user_deliveries'
  get 'users/orders', to: 'users#orders', as: 'user_orders'

  resources :orders do
    member do
      get 'deliver'
      get 'confirm'
    end
    collection do
      post 'search'
    end
  end
end
