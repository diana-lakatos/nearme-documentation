DesksnearMe::Application.routes.draw do

  if Rails.env.development?
    mount ReservationMailer::Preview => 'mail_view/reservations'
    mount UserMailer::Preview => 'mail_view/users'
    mount InquiryMailer::Preview => 'mail_view/inquiries'
    mount ListingMailer::Preview => 'mail_view/listings'
    mount AfterSignupMailer::Preview => 'mail_view/after_signup'
    mount RatingMailer::Preview => 'mail_view/ratings'
  end

  match '/404', :to => 'errors#not_found'
  match '/422', :to => 'errors#server_error'
  match '/500', :to => 'errors#server_error'

  namespace :admin do
    match '/', :to => "dashboard#show"
    resources :users do
      member do
        post :login_as
      end

      collection do
        post :restore_session
      end
    end

    resources :reservations
    resources :companies
    resources :payment_transfers do
      member do
        post :transferred
      end

      collection do
        post :generate
      end
    end

    resources :instances
    resources :pages
  end

  resources :companies
  resources :locations, :only => [:show] do
    resources :listings, :controller => 'locations/listings'

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
    resources :reservations, :only => [:create, :update], :controller => "listings/reservations" do
      post :review, :on => :collection
      get :hourly_availability_schedule, :on => :collection
     end
  end

  resources :reservations, :only => [] do
    resources :guest_ratings, :only => [:new, :create]
    resources :host_ratings, :only => [:new, :create]
  end

  match '/auth/:provider/callback' => 'authentications#create'
  match "/auth/failure", to: "authentications#failure"
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions', :passwords => 'passwords' }
  devise_scope :user do
    put "users/avatar", :to => "registrations#avatar", :as => "avatar"
    get "users/", :to => "registrations#new"
    get "users/verify/:id/:token", :to => "registrations#verify", :as => "verify_user"
    delete "users/avatar", :to => "registrations#destroy_avatar", :as => "destroy_avatar"
  end

  resources :reservations do
    member do
      post :user_cancel
      get :export
      get :guest_rating
      get :host_rating
    end
    collection do
      get :upcoming
      get :archived
    end
  end

  resource :dashboard, :only => [:show], :controller => 'dashboard' do
    member do
      get :bookings, :to => 'reservations#upcoming'
      get :payments
      get :listings
      get :manage_guests
    end
  end

  namespace :manage do

    resources :companies, :only => [:edit, :update]

    resources :locations do
      collection do
        get 'data_import'
      end
      resources :listings
    end

    resources :photos, :only => [:create, :destroy, :edit, :update] do
      collection do
        put '', :to => :create # it's a dirty hack for photo uploader, in edit listing/location it uses PUT instead of POST.. put '' matches manage/photos
      end
    end

    resources :listings do
      resources :reservations, :controller => 'listings/reservations' do
        member do
          post :confirm
          put :reject
          get :rejection_form
          post :host_cancel
        end
      end
    end
  end

  match "/search", :to => "search#index", :as => :search
  match "/search/show/:id", :to => "search#show"

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

  match "/pages/:path", to: 'pages#show', as: :pages
  match "/w-hotels-desks-near-me", to: 'locations#w_hotels', as: :w_hotels_location
  match "/W-hotels-desks-near-me", to: 'locations#w_hotels'
  match "/careers", to: 'pages#careers'
  match "/rent-accounting-desks", to: 'locations#vertical_accounting'
  match "/rent-legal-desks", to: 'locations#vertical_law'
  match "/rent-hairdressing-booth-stations", to: 'locations#vertical_hairdressing'
  match "/rent-design-desks", to: 'locations#vertical_design'
end
