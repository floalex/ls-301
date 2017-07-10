Rails.application.routes.draw do
  root to: 'users#index'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/timeline', to: 'users#timeline'
  get '/mentions', to: 'users#mentions'

  resources :users, only: [:new, :create] do
    member do
      post 'follow'
      post 'unfollow'
    end
  end
  resources :statuses, only: [:new, :create, :index, :show] do
    member do
      post 'retweet'
    end
  end



  resources :hashtags, only: [:show]

  get "/:username", to: 'users#show', as: 'user'
end
