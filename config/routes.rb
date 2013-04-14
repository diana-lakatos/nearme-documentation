DesksnearMe::Application.routes.draw do

  if Rails.env.development?
    mount ReservationMailer::Preview => 'mail_view/reservations'
    mount InquiryMailer::Preview => 'mail_view/inquiries'
    mount ListingMailer::Preview => 'mail_view/listings'
    mount AfterSignupMailer::Preview => 'mail_view/after_signup'
  end

  resources :companies
  resources :locations, :only => [:show] do
    resources :listings, :controller => 'locations/listings'
    resources :reservations, :controller => 'locations/reservations', :only => [:create] do
      post :review, :on => :collection
    end

    member do
      get :host
      get :networking
    end

    collection do
      get :populate_address_components_form
      post :populate_address_components
    end
  end

  resources :listings, :only => [:index, :show] do
    resources :reservations, :only => [:new, :create, :update], :controller => "listings/reservations" do
      post :confirm
      post :reject
    end
  end

  match '/auth/:provider/callback' => 'authentications#create'
  match "/auth/failure", to: "authentications#failure"
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions', :passwords => 'passwords' } 
  devise_scope :user do
    put "users/avatar", :to => "registrations#avatar", :as => "avatar"
    get "users/", :to => "registrations#new"
    delete "users/avatar", :to => "registrations#destroy_avatar", :as => "destroy_avatar"
  end

  resources :reservations, :only => :update

  ## routing after 'dashboard/' is handled in backbone cf. router.js
  get 'dashboard' => 'dashboard#index', as: :controlpanel
  get 'dashboard/locations' => 'dashboard#index', as: :controlpanel

  resource :dashboard, :only => [:show], :controller => 'dashboard' do
    member do
      get :bookings
      get :listings
      get :manage_guests
    end
  end

  namespace :manage, :path => 'dashboard' do
    resources :companies do
      resources :locations, :only => [:index] do
      end
    end

    resources :locations do
      resources :listings, :only => [:index, :new, :create]
      member do
        get :map
        get :amenities
        get :availability
        get :photos
        get :associations
      end
    end

    resources :listings do
      resources :photos
    end
  end

  match "/search", :to => "search#index", :as => :search

  resources :authentications do
    collection do
      post :clear # Clear authentications stored in session
    end
  end

  scope '/space' do
    get '/new' => 'space_wizard#new', :as => "new_space_wizard"
    get "/list" => "space_wizard#list", :as => "space_wizard_list"
    post "/list" => "space_wizard#submit_listing"
    put "/list" => "space_wizard#submit_listing"
    post "/photo" => "space_wizard#submit_photo", :as => "space_wizard_photo"
    put "/photo" => "space_wizard#submit_photo", :as => "space_wizard_photo"
    delete "/photo" => "space_wizard#destroy_photo", :as => "destroy_space_wizard_photo"
  end

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

    resources :locations do
      collection do
        get 'list'
      end
    end

    resources :photos

    resources :listings, :only => [:show,:create, :update, :destroy] do
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

  match "/legal", to: 'pages#legal'
  match "/host-sign-up", to: 'pages#host_signup_1'
  match "/host-sign-up-2", to: 'pages#host_signup_2'
  match "/host-sign-up-3", to: 'pages#host_signup_3'
  match "/w-hotels-desks-near-me", to: 'pages#w_hotels'
  match "/W-hotels-desks-near-me", to: 'pages#w_hotels'
  match "/careers", to: 'pages#careers'
  match "/support" => redirect("https://desksnearme.desk.com")

end
