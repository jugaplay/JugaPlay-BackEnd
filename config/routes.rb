Rails.application.routes.draw do
  devise_for :users,
             path: 'api/v1/users',
             controllers: {
               registrations: 'api/v1/users/registrations',
               sessions: 'api/v1/users/sessions',
               confirmations: 'api/v1/users/confirmations',
               passwords: 'api/v1/users/passwords',
               unlocks: 'api/v1/users/unlocks',
               omniauth_callbacks: 'api/v1/users/omniauth_callbacks'
             }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post 'login' => 'users/sessions#create'
        delete 'logout' => 'users/sessions#destroy'
      end

      resources :users, only: [:show, :create, :update] do
      	resources :explanations, only: [:index, :show, :create]
      	resources :requests, only: [:index, :create]
      end

      resources :requests, only: [] do
        resources :registrations, only: [:create]
      end

      resources :tournaments, only: [] do
        resources :rankings, only: [:index]
      end

      resources :tables, only: [:index, :show] do
        resources :matches, only: [:index]
      end

      resources :matches do
        resources :players do
          member do
            get 'stats' => 'players#stats', as: :stats
          end
        end
      end

      resources :teams, only: [:show]
      resources :plays, only: [:index]
      resources :comments, only: [:create]
	  resources :guests, only: [:index, :show]
	  resources :transactions, only: [:show, :create]
	  
	
      post '/play' => 'croupier#play'
    end
  end

  namespace :admin do
    root 'home#index'

    devise_scope :user do
      get '/login' => 'sessions#new'
      post '/login' => 'sessions#create'
      get '/logout' => 'sessions#destroy'
    end

    resources :users, only: [:index]
    resources :players, only: [:index, :new, :create, :show, :edit, :update, :destroy]
    resources :transactions, only: [:index]


    resources :teams, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      member do
        post 'import_players' => 'teams#import_players', as: :import_players
      end
    end

    resources :matches, only: [:index, :new, :create, :show, :edit, :update, :destroy]
    
    resources :tables, only: [:index, :new, :create, :show, :edit, :update, :destroy] do    
      collection do
        get 'to_be_closed' => 'tables#to_be_closed', as: :to_be_closed
      end

      member do
        post 'close' => 'tables#close', as: :close
      end
    
      resources :prizes, only: [:index, :new, :create, :edit, :update]
      
    end
    
  end
end