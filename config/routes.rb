 Rails.application.routes.draw do
  devise_for :users,
             path: 'api/v1/users',
             controllers: {
               sessions: 'api/v1/users/sessions',
               confirmations: 'api/v1/users/confirmations',
               passwords: 'api/v1/users/passwords',
               unlocks: 'api/v1/users/unlocks',
               omniauth_callbacks: 'api/v1/users/omniauth_callbacks'
             }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      get 'mailer/send_request'
      post 'mailer/send_request'

      ###########################################
      #                                         #
      #                 USERS                   #
      #                                         #
      ###########################################

      devise_scope :user do
        post 'login' => 'users/sessions#create'
        delete 'logout' => 'users/sessions#destroy'
      end

      resources :users, only: [:show, :create, :update] do
        collection do
          post 'search' => 'users#search', as: :search
        end
      end

      resources :groups, only: [:index, :show, :create, :update] do
        member do
          put 'add_member/:user_id' => 'groups#add_member'
          post 'exit' => 'groups#exit'
        end

        collection do
          post 'join' => 'groups#join'
        end
      end

      resources :address_books, only: [] do
        collection do
          post 'synch' => 'address_books#synch', as: :synch
          get '/' => 'address_books#show', as: :show
        end
      end

      resources :telephone_update_requests, only: [] do
        collection do
          post 'validate' => 'telephone_update_requests#validate', as: :validate
        end
      end

      resources :invitation_requests, only: [:index, :create] do
        collection do
          post 'visit' => 'invitation_requests#visit', as: :visit
          post 'accept' => 'invitation_requests#accept', as: :accept
        end
      end

      resources :explanations, only: [:index, :show, :create]
      resources :notifications, only: [:index, :update]
      resources :notifications_settings, only: [:update] do
        collection do
          get '' => 'notifications_settings#show', as: :show
        end
      end



      ###########################################
      #                                         #
      #                  GAME                   #
      #                                         #
      ###########################################

      resources :tournaments, only: [] do
        resources :rankings, only: [:index]
      end

      resources :tables, only: [:index, :show, :create] do
        resources :matches, only: [:index]
        member do
          post 'multiply_play/:multiplier' => 'tables#multiply_play', as: :multiply_play
        end
      end

      resources :matches do
        resources :players do
          member do
            get 'stats' => 'players#stats', as: :stats
          end
        end
      end

      resources :teams, only: [:show]
      resources :plays, only: [:index, :show]
      resources :leagues, only: [:index, :show] do
        collection do
          get 'actual' => 'leagues#actual', as: :actual
        end
      end

      post '/play' => 'croupier#play'

      resources :table_rankings, only: [:index]



      ###########################################
      #                                         #
      #                 UNKNOWN                 #
      #                                         #
      ###########################################

      resources :comments, only: [:create]
      resources :t_entry_fees, only: [:index]
      resources :transactions, only: [:index, :show, :create]
      resources :t_deposits, only: [:index, :create]
      resources :t_withdraws, only: [:index, :create]
      resources :t_promotions, only: [:index, :create]
      resources :wallet_history, only: [:index]
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

    resources :player_stats, only: [] do
      collection do
        post 'import' => 'player_stats#import', as: :import
        get 'import_form' => 'player_stats#import_form', as: :import_form
      end
    end

    resources :matches, only: [:index, :new, :create, :show, :edit, :update, :destroy]
    
    resources :tables, only: [:index, :new, :create, :show, :edit, :update, :destroy] do    
      collection do
        get 'to_be_closed' => 'tables#to_be_closed', as: :to_be_closed
        get 'close_all' => 'tables#close_all', as: :close_all
      end

      member do
        post 'close' => 'tables#close', as: :close
      end
    end
  end
end