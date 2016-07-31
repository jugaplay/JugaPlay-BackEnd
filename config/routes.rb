Rails.application.routes.draw do
 

  namespace :api do
  namespace :v1 do
    get 'mailer/send_request'
    end
  end

  get 'mailer/api/v1/send_request'

  devise_for :users,
             path: 'api/v1/users',
             controllers: {
               invitations: 'api/v1/users/invitations',
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
      	resources :channels, only: [:index, :update]
      	resources :notifications, only: [:index, :create]
      end      

      resources :requests, only: [] do
        resources :invitations, only: [:create,:update]
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
	  resources :wallet_history, only: [:index]
	  resources :unused_invitations, only: [:index]
	  resources :registered_invitations, only: [:index]
	  
	
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
	resources :sent_mails, only: [:index, :create]
	resources :explanations, only: [:index, :new, :create, :show, :edit, :update]

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