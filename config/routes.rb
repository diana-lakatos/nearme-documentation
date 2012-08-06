DesksnearMe::Application.routes.draw do

  resources :workplaces do
    resources :photos
    resources :bookings, :only => [:new, :create, :update], :controller => "workplaces/bookings" do
      post :confirm
      post :reject
    end
  end

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }

  resources :bookings, :only => :update

  match "/dashboard", :to => "dashboard#index", :as => :dashboard

  match "/search", :to => "search#index", :as => :search

  resources :authentications

  root :to => "public#index"

  namespace :v1, :defaults => { :format => 'json' } do

    resource :authentication, only: [:create]
    post 'authentication/:provider', :to => 'authentications#social'

    resource :registration, only: [:create]

    get  'profile',  :to => 'profile#show'
    put  'profile',  :to => 'profile#update'
    post 'profile/avatar/:filename', :to => 'profile#upload_avatar'
    delete 'profile/avatar', :to => 'profile#destroy_avatar'

    get  'iplookup',  :to => 'iplookup#index'

    resources :listings, :only => [:show] do
      member do
        post 'reservation'
        post 'availability'
        post 'inquiry'
        post 'share'
        get  'patrons'
        get  'connections'
      end
      collection do
        post 'search'
        post 'query'
      end
      resource :rating, only: [:show, :update, :destroy]
    end

    resources :reservations do
      collection do
        get 'past'
        get 'future'
      end
    end

    resource :social, only: [:show], controller: 'social' do
      # Hmm, can this be better?
      resource :facebook, only: [:show, :update, :destroy],
                          controller: 'social_provider', provider: 'facebook'
      resource :twitter,  only: [:show, :update, :destroy],
                          controller: 'social_provider', provider: 'twitter'
      resource :linkedin, only: [:show, :update, :destroy],
                          controller: 'social_provider', provider: 'linkedin'
    end

    get 'amenities', to: 'amenities#index'
    get 'organizations', to: 'organizations#index'
  end
end
