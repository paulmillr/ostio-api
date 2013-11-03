Ostio::Application.routes.draw do
  devise_for :users, only: [], controllers: {
    omniauth_callbacks: 'omniauth_callbacks'
  }

  devise_scope :user do
    match '/auth/github/callback' => 'omniauth_callbacks#github'
  end

  namespace :v1 do
    match '/users/me' => 'users#show_current'
    resources :users, constraints: {id: /[\w.-]+/} do
      resources :repos, constraints: {id: /[\w.-]+/}, except: :edit do
        resources :topics, except: :edit do
          resources :posts, except: :edit
        end
      end

      get '/posts/' => 'posts#by_user'
      resources :sync_repos, only: [:create]
    end
    get '/posts/' => 'posts#latest'
    get '/' => 'home#index'
  end

  match '/404', to: 'errors#not_found'
  match '/418', to: 'errors#i_am_a_teapot'
  match '/500', to: 'errors#server_error'
  get '/' => 'v1/home#index'
end
