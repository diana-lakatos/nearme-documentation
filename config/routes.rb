DesksnearMe::Application.routes.draw do

  if Rails.env.development?
    mount ReservationMailer::Preview => 'mail_view/reservations'
    mount InquiryMailer::Preview => 'mail_view/inquiries'
    mount ListingMailer::Preview => 'mail_view/listings'
  end

  resources :companies
  resources :locations do
    resources :listings, :controller => 'locations/listings'
    resources :reservations, :controller => 'locations/reservations', :only => [:create] do
      post :review, :on => :collection
    end

    member do
      get :host
      get :networking
      get :availability_summary
    end
  end

  resources :listings do
    resources :photos
    resources :reservations, :only => [:new, :create, :update], :controller => "listings/reservations" do
      post :confirm
      post :reject
    end
  end

  resources :organizations

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions', :passwords => 'passwords' }

  resources :reservations, :only => :update

  match "/dashboard", :to => "dashboard#index", :as => :dashboard

  match "/search", :to => "search#index", :as => :search

  resources :authentications do
    collection do
      post :clear # Clear authentications stored in session
    end
  end

  scope '/space' do
    get '/new' => 'space_wizard#new', :as => "new_space_wizard"
    get '/complete' => "space_wizard#complete", :as => "space_wizard_complete"

    %w(company space desks).each do |step|
      get "/#{step}" => "space_wizard##{step}", :as => "space_wizard_#{step}"
      post "/#{step}" => "space_wizard#submit_#{step}"
      put "/#{step}" => "space_wizard#submit_#{step}"
    end
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

  match "/privacy", to: 'pages#privacy'
  match "/support" => redirect("https://desksnearme.desk.com")

end
