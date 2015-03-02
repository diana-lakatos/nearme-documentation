# super hackish way to fix add_space_wizard:12 feature
require Rails.root.join('app', 'controllers', 'registrations_controller.rb') if Rails.env.test?

DesksnearMe::Application.routes.draw do

  scope module: 'buy_sell_market' do
    resources :products, only: [:show]

    resources :orders, only: [:show, :index] do
      resources :checkout do
        collection do
          get 'get_states'
        end
      end
    end

    namespace :cart do
      get '/', action: 'index', as: 'index'
      delete 'empty'
      delete 'clear_all/:order_id', action: 'clear_all', as: 'clear_all'
      patch 'update'
      get 'add', action: 'add', as: 'add_product' # Get is for redirection after login
      delete 'remove/:item_id', action: 'remove', as: 'remove_product'
      get 'next/:order_id', action: 'next', as: 'next'
    end
  end

  get '/t/*taxon', to: 'search#index', as: :buy_sell_taxon

  mount CustomAttributes::Engine, at: '/custom_attributes'

  get 'ping', to: 'ping#index'

  mount Ckeditor::Engine => '/ckeditor'

  constraints host: 'near-me.com' do
    get '/features-setup', :to => 'platform_home#features_setup'
    get '/features-design', :to => 'platform_home#features_design'
    get '/features-manage', :to => 'platform_home#features_manage'
    get '/features-marketing', :to => 'platform_home#features_marketing'
    get '/features-payments', :to => 'platform_home#features_payments'
    get '/features-analytics', :to => 'platform_home#features_analytics'
    get '/features-security', :to => 'platform_home#features_security'
    get '/features-integration', :to => 'platform_home#features_integration'
    get '/features-support', :to => 'platform_home#features_support'
    get '/', :to => 'platform_home#index'
    get '/features', :to => 'platform_home#features'
    get '/clients', :to => 'platform_home#clients'
    get '/contact', :to => 'platform_home#contact'
    post '/contact-submit', :to => 'platform_home#contact_submit'
    get '/about', :to => 'platform_home#about'
    get '/brand', :to => 'platform_home#brand'
    get '/press-media', :to => 'platform_home#press_media'
    get '/careers', :to => 'platform_home#careers'
    get '/advisors', :to => 'platform_home#advisors'
    get '/faq-page', :to => 'platform_home#faq_page'
    get '/privacy-policy', :to => 'platform_home#privacy_policy'
    get '/unsubscribe/:unsubscribe_key', :to => 'platform_home#unsubscribe', :as => 'platform_email_unsubscribe'
    get '/resubscribe/:resubscribe_key', :to => 'platform_home#resubscribe', :as => 'platform_email_resubscribe'

    get '/marketplace', to: 'instance_wizard#index'
    get '/marketplace/new', to: 'instance_wizard#new'
    post '/marketplace/new', to: 'instance_wizard#new'
    post '/marketplace/create', to: 'instance_wizard#create'

    get '/blog', to: redirect("http://blog.near-me.com", status: 301)

    constraints protocol: 'https://' do # Read the commit message for rationale
      get '/demo-requests/DsNvigiE6I9ZGwtsFGrcIw', :to => 'platform_home#demo_requests'
      get '/contacts/tgKQstjun1AgHWJ1kgevNg', :to => 'platform_home#contacts'
    end
  end

  root :to => "home#index"

  get '/404', :to => 'errors#not_found'
  get '/422', :to => 'errors#server_error'
  get '/500', :to => 'errors#server_error'

  namespace :support do
    root :to => 'dashboard#index'
    resources :tickets, only: [:index, :new, :create, :show] do
      resources :ticket_messages, only: [:create]
      resources :ticket_message_attachments, only: [:new, :create, :edit, :update, :destroy], controller: 'tickets/ticket_message_attachments'
    end
    resources :ticket_message_attachments, only: [:new, :create, :edit, :update, :destroy]
    resources :requests_for_quotes, only: [:index]
  end

  namespace :admin do
    namespace :blog do
      get '/', :to => redirect("/admin/blog/blog_posts")
      resources :blog_posts
      resource :blog_instance, only: [:edit, :update]
    end

    get '/', :to => "dashboard#show"
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

    resources :instance_creators

    resources :instances, :only => [:index, :show, :edit, :update] do
      member do
        post :lock
      end
      resources :transactable_types do
      end
      resources :partners
      resources :instance_views
    end
    resources :transactable_types, :only => [] do
      resources :custom_attributes
    end
    resources :pages
    get '/platform_home', to: 'platform_home#edit', as: 'edit_platform_home'
    post '/platform_home', to: 'platform_home#update', as: 'platform_home'
  end

  resources :marketplace_sessions, only: [:new, :create]
  get '/wish_list/add_item', to: 'wish_list#add_item'
  get '/wish_list/remove_item', to: 'wish_list#remove_item'

  namespace :instance_admin do
    get '/', :to => 'base#index'

    namespace :analytics do
      get '/', :to => 'base#index'
      resource :overview, :only => [:show], :controller => 'overview'
      resource :sales, :only => [:show]
      resource :profiles, :only => [:show]
    end

    namespace :settings do
      get '/', :to => 'base#index'
      resources :domains, except: :show
      resource :hidden_controls, only: [:show, :update], :controller => 'hidden_controls'
      resource :certificate_request, only: [:new, :create]
      resource :configuration, :only => [:show, :update], :controller => 'configuration' do
        collection do
          post :lock
        end
      end
      resource :integrations, :only => [:show, :update], :controller => 'integrations' do
        collection do
          post :countries
          post :payment_gateways
          post :country_instance_payment_gateway
          get :country_instance_payment_gateways
          match :create_or_update_instance_payment_gateway, via: [:post, :put, :patch]
        end
      end
      resource :locations, :only => [:show, :update], :controller => 'locations'
      resources :location_types, only: [:index, :create, :update, :destroy_modal, :destroy] do
        get 'destroy_modal', on: :member
      end
      resource :listings, :only => [:show, :update], :controller => 'listings'
      resources :listing_types, only: [:index, :create, :destroy_modal, :destroy] do
        get 'destroy_modal', on: :member
      end
      resource :translations, :only => [:show, :update], :controller => 'translations'
      resource :cancellation_policy, :only => [:show, :update], :controller => 'cancellation_policy'
      resource :documents_upload, except: [:index, :destroy], :controller => 'documents_upload'
    end

    namespace :theme do
      get '/', :to => 'base#index'
      resource :info, :only => [:show, :update], :controller => 'info'
      resource :design, :only => [:show, :update], :controller => 'design' do
        member do
          delete 'destroy_image/:image', :action => :destroy_image, :as => 'destroy_theme_image'
          get 'edit_image/:image', :action => :edit_image, :as => 'edit_theme_image'
          match 'update_image/:image', :action => :update_image, :as => 'update_theme_image', via: [:post, :put]
          match 'upload_image/:image', :action => :upload_image, :as => 'upload_theme_image', via: [:post, :put]
        end
      end
      resources :pages
      resource :footer, only: [:show, :create, :update], controller: 'footer'
      resource :homepage, only: [:show, :update], controller: 'homepage'
      resource :homepage_template, only: [:show, :create, :update], controller: 'homepage_template'
    end

    namespace :manage do
      get '/', :to => 'base#index'
      get 'support' => 'support#index', as: 'support_root'
      namespace :support do
        resources :faqs, except: [:show]
        resources :tickets, only: [:show, :update] do
          resources :ticket_messages, only: [:create]
        end
      end

      resources :reviews, only: [:index]
      resources :rating_systems, only: [:index] do
        put '/update_systems', to: 'rating_systems#update_systems', on: :collection
      end

      resources :approval_requests, only: [:index, :edit, :update]
      resources :approval_request_templates do
        resources :approval_request_attachment_templates, controller: 'approval_request_templates/approval_request_attachment_templates'
      end

      resources :custom_attributes, only: [:index]
      resources :workflows, only: [:index, :edit, :update, :show] do
        resources :workflow_steps, only: [:show, :edit, :update], controller: 'workflows/workflow_steps'
      end
      resources :workflow_steps do
        resources :workflow_alerts, except: [:index], controller: 'workflows/workflow_alerts'
      end

      resources :instance_profile_types, :only => [:index, :destroy] do
        collection do
          post :enable
        end
        resources :custom_attributes, controller: 'instance_profile_types/custom_attributes'
      end

      resources :transactable_types do
        put :change_state, on: :member
        resources :custom_attributes, controller: 'transactable_types/custom_attributes'
        resources :data_uploads, controller: 'transactable_types/data_uploads' do
          collection do
            get :download_csv_template
          end
          member do
            post :schedule_import
          end
        end
        resources :form_components, controller: 'transactable_types/form_components' do
          member do
            patch :update_rank
          end
          collection do
            post :create_as_copy
          end
        end
      end

      resources :users, only: [:index] do
        post :login_as, on: :member
        post :restore_session, on: :collection
        resources :user_bans, only: [:create, :index, :destroy], controller: 'users/user_bans'
      end

      resources :transfers do
        member do
          post :transferred
          post :payout
        end

        collection do
          post :generate
        end
      end

      resources :partners

      resources :admins, :only => [:index, :create]
      namespace :admins do
        resources :instance_admins, :only => [:create, :update, :destroy, :index]
        resources :instance_admin_roles, :only => [:create, :update, :destroy, :index]
      end

      resources :email_layout_templates, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :email_templates, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :sms_templates, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :waiver_agreement_templates, :only => [:index, :create, :update, :destroy]

      resource :wish_lists, only: [:show, :update]
    end

    namespace :manage_blog do
      get '/', :to => 'base#index'
      resources :posts
      resources :user_posts
      resource :settings, only: [:edit, :update]
    end

    namespace :buy_sell do
      get '/', :to => 'base#index'
      resource :configuration, only: [:show, :update], controller: 'configuration'
      resource :commissions, :only => [:show, :update], :controller => 'commissions'
      resources :product_types do
        resources :custom_attributes, controller: 'product_types/custom_attributes'
        resources :form_components, controller: 'product_types/form_components' do
          member do
            patch :update_rank
          end
          collection do
            post :create_as_copy
          end
        end
      end
      resources :tax_categories
      resources :tax_rates
      resources :zones
      resources :taxonomies do
        member do
          get :jstree
        end
        resources :taxons do
          member do
            get :jstree
          end
        end
      end
      
      resources :shipping_categories
      resources :shipping_methods
    end

    namespace :shipping_options do
      resource :providers
      resources :dimensions_templates
    end

  end

  resources :blog_posts, path: 'blog', only: [:index, :show], controller: 'blog/blog_posts'

  resources :transactable_types, only: [] do
    resources :locations, :only => [] do
      member do
        get "(:listing_id)", :to => "locations#show", :as => ''
      end

      resources :listings, :controller => 'locations/listings', :only => [:show] do
        member do
          get :ask_a_question
        end
      end

      resource :social_share, :only => [:new], :controller => 'locations/social_share'
      end
  end

  resources :locations, :only => [] do
    member do
      get "(:listing_id)", :to => "locations#show", :as => ''
    end

    resources :listings, :controller => 'locations/listings', :only => [:show] do
      member do
        get :ask_a_question
      end
    end

    resource :social_share, :only => [:new], :controller => 'locations/social_share'

    collection do
      get :populate_address_components_form
      post :populate_address_components
    end
  end

  resources :listings, :only => [:index, :show] do

    resources :recurring_bookings, :only => [:create, :update], :controller => "listings/recurring_bookings" do
      collection do
        post :review
        post :store_recurring_booking_request
      end

      member do
        get :booking_successful
      end
    end

    resources :tickets, only: [:new, :create], :controller => 'listings/support/tickets'

    resources :reservations, :only => [:create, :update], :controller => 'listings/reservations' do
      collection do
        post :review
        post :store_reservation_request
      end

      member do
        get :remote_payment
      end

      get :hourly_availability_schedule, :on => :collection
    end

  end


  match '/auth/:provider/callback' => 'authentications#create', via: [:get, :post]
  get "/auth/failure", to: "authentications#failure"
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions', :passwords => 'passwords' }
  devise_scope :user do
    post "users/avatar", :to => "registrations#avatar", :as => "avatar"
    get "users/edit_avatar", :to => "registrations#edit_avatar", :as => "edit_avatar"
    match "users/update_avatar", :to => "registrations#update_avatar", :as => "update_avatar", via: [:patch, :put]
    get "users/set_password", :to => "registrations#set_password", :as => "set_password"
    match "users/update_password", :to => "registrations#update_password", :as => "update_password", via: [:patch, :put]
    get "users/edit_notification_preferences", :to => "registrations#edit_notification_preferences", :as => "edit_notification_preferences"
    match "users/update_notification_preferences", :to => "registrations#update_notification_preferences", :as => "update_notification_preferences", via: [:patch, :put]
    post "users/store_google_analytics_id", :to => "registrations#store_google_analytics_id", :as => "store_google_analytics"
    post "users/store_geolocated_location", :to => "registrations#store_geolocated_location", :as => "store_geolocated_location"
    get "users/", :to => "registrations#new"
    get "users/verify/:id/:token", :to => "registrations#verify", :as => "verify_user"
    delete "users/avatar", :to => "registrations#destroy_avatar", :as => "destroy_avatar"
    get "users/:id", :to => "registrations#show", :as => "profile"
    get "users/:user_id/blog", :to => "registrations/blog#index", :as => "user_blog_posts_list"
    get "users/:user_id/blog/:id", :to => "registrations/blog#show", :as => "user_blog_post_show"
    get "users/unsubscribe/:signature", :to => "registrations#unsubscribe", :as => "unsubscribe"
    get "dashboard/edit_profile", :to => "registrations#edit", :as => "dashboard_profile"
    get "dashboard/social_accounts", :to => "registrations#social_accounts", :as => "social_accounts"

    match "users/store_correct_ip", :to => "sessions#store_correct_ip", :as => "store_correct_ip", via: [:patch, :put]

    get "/instance_admin/sessions/new", :to => "instance_admin/sessions#new", :as => 'instance_admin_login'
    post "/instance_admin/sessions", :to => "instance_admin/sessions#create"
    delete "/instance_admin/sessions", :to => "instance_admin/sessions#destroy"
  end

  resources :listings, :users, :reservations, :products do
    resources :user_messages, controller: "dashboard/user_messages", except: [:index] do
      patch :archive
      put :archive
    end
  end

  namespace :dashboard do

    resources :api do
      collection do
        get :countries
        get :states
        get :taxons
      end
    end

    resource :blog, controller: 'user_blog/blog', only: [:show, :edit, :update] do
      resources :posts, controller: 'user_blog/blog_posts'
    end
    
    namespace :company do
      resource :analytics
      resources :orders_received, except: [:edit] do
        member do
          get :approve
          get :cancel
          get :resume
        end

        resources :payments do
          member do
            get :capture
          end
        end

        resources :shipments do
          member do
            get :ship
          end
        end
      end

      resources :host_reservations do
        member do
          post :confirm
          get :confirm
          patch :reject
          put :reject
          get :rejection_form
          post :host_cancel
          get :request_payment
        end
      end

      resources :locations
      resources :payment_documents do
        collection do
          get :sent_to_me
          get :uploaded_by_me
        end
      end
      resource :payouts, except: [:index, :show, :new, :create, :destroy]
      resources :products
      resources :product_type do
        resources :products
      end

      resources :transactable_types do
        resources :transactables do
          member do
            get :enable
            get :disable
          end
        end

        resources :data_uploads, controller: 'transactable_types/data_uploads' do
          collection do
            get :status
            get :download_csv_template
            get :download_current_data_csv
          end
          member do
            post :schedule_import
          end
        end
      end
      resource :transfers
      resources :users, :except => [:edit, :update]
      resources :waiver_agreement_templates, only: [:index, :edit, :new, :update, :create, :destroy]

      resources :white_labels, :only => [:edit, :update, :show] do
        member do
          delete 'destroy_image/:image', :action => :destroy_image, :as => 'destroy_theme_image'
          get 'edit_image/:image', :action => :edit_image, :as => 'edit_theme_image'
          match 'update_image/:image', :action => :update_image, :as => 'update_theme_image', via: [:post, :put]
          match 'upload_image/:image', :action => :upload_image, :as => 'upload_theme_image', via: [:post, :put]
        end
      end
    end #ends company namespace

    resources :companies, :only => [:edit, :update, :show]
    resources :host_recurring_bookings do
      member do
        post :confirm
        get :confirm
        patch :reject
        put :reject
        get :rejection_form
        post :host_cancel
      end
    end

    resources :images
    resources :orders, only: [:index, :show]
    resources :photos, :only => [:create, :destroy, :edit, :update]
    resources :reviews, :only => [:index, :create, :update, :destroy]
    namespace :support do
      resources :tickets, only: [:show, :index] do
        resources :ticket_messages, only: [:create]
        resources :ticket_message_attachments, only: [:create, :edit, :update, :destroy]
      end
    end

    resources :transactable_types, only: [] do
      resources :listings, only: [:new, :create] do
      end
    end

    resources :user_messages, only: [:index, :show] do
      collection do
        get :archived
      end
    end

    resources :user_reservations, :except => [:update, :destroy, :show] do
      member do
        post :user_cancel
        get :export
        get :booking_successful
        get :booking_failed
        get :booking_successful_modal
        get :recurring_booking_successful_modal
        get :booking_failed_modal
        get :remote_payment
        get :remote_payment_modal
        get :recurring_booking_successful
      end
      collection do
        get :upcoming
        get :archived
      end
    end

    resources :user_recurring_bookings, :except => [:destroy] do
      member do
        post :user_cancel
        get :export
        get :booking_successful
        get :upcoming
        get :archived
      end
    end

    resources :wish_list_items, only: [:index, :destroy], path: 'favorites' do
      collection do
        delete :clear
      end
    end

  end #end /dashboard namespace

  resources :reservations do
    resources :payment_notifications, controller: 'reservations/payment_notifications'
  end

  get '/dashboard', controller: 'dashboard/dashboard', action: 'index'

  get "/search", :to => "search#index", :as => :search

  resources :search_notifications, only: [:create]

  resource :event_tracker, only: [:create], :controller => 'event_tracker'

  resources :authentications, :only => [:create, :destroy] do
    collection do
      post :clear # Clear authentications stored in session
    end
  end


  resources :transactable_types do
    get '/new', as: "new_space_wizard", controller: 'transactable_types/space_wizard', action: 'new'
    get "/list", as: "space_wizard_list", controller: 'transactable_types/space_wizard', action: 'list'
    post "/list", controller: 'transactable_types/space_wizard', action: 'submit_listing'
    post "/submit_item", controller: 'transactable_types/space_wizard', action: 'submit_item'
  end

  resources :product_types do
    resources :product_wizard, only: [:new, :create], controller: 'product_types/product_wizard'
  end

  scope '/space' do
    get '/new' => 'space_wizard#new', :as => "new_space_wizard"
    get "/list" => "space_wizard#list", :as => "space_wizard_list"
    post "/list" => "space_wizard#submit_listing"
    match "/list" => "space_wizard#submit_listing", via: [:put, :patch]
    match "/photo" => "space_wizard#submit_photo", :as => "space_wizard_photo", via: [:post, :put]
    delete "/photo/:id" => "space_wizard#destroy_photo", :as => "destroy_space_wizard_photo"
  end

  resources :partner_inquiries, :only => [:index, :create], :controller => 'partner_inquiries', :path => 'partner'
  resources :waiver_agreement_templates, only: [:show]

  namespace :v1, :defaults => { :format => 'json' } do

    resource :authentication, only: [:create]
    post 'authentication/:provider', :to => 'authentications#social'

    resource :registration, only: [:create]

    get 'profile', :to => 'profile#show'
    match 'profile', :to => 'profile#update', via: [:put, :patch]
    post 'profile/avatar/:filename', :to => 'profile#upload_avatar'
    delete 'profile/avatar', :to => 'profile#destroy_avatar'

    get 'iplookup', :to => 'iplookup#index'

    resources :locations do
      collection do
        get 'list'
      end
    end

    resources :photos

    resources :listings, only: [:show, :create, :update, :destroy] do
      member do
        post 'reservation'
        post 'availability'
        post 'inquiry'
        post 'share'
        get 'patrons'
        get 'connections'
      end
      collection do
        post 'search'
        post 'query'
      end
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
      resource :twitter, only: [:show, :update, :destroy],
               controller: 'social_provider', provider: 'twitter'
      resource :linkedin, only: [:show, :update, :destroy],
               controller: 'social_provider', provider: 'linkedin'
    end

    get 'amenities', to: 'amenities#index'
    get 'organizations', to: 'organizations#index'
  end

  get "/dashboard/api", to: 'dashboard#api', as: :spree
  get "/pages/:path", to: 'pages#show', as: :pages
  get "/w-hotels-desks-near-me", to: 'locations#w_hotels', as: :w_hotels_location
  get "/W-hotels-desks-near-me", to: 'locations#w_hotels'
  get "/careers", to: 'pages#careers'
  get "/rent-accounting-desks", to: 'locations#vertical_accounting'
  get "/rent-legal-desks", to: 'locations#vertical_law'
  get "/rent-hairdressing-booth-stations", to: redirect(subdomain: 'rent-salon-space', path: '/')
  get "/rent-design-desks", to: 'locations#vertical_design'

  if defined? MailView
    mount PlatformMailerPreview => 'mail_view/platform'
  end

end
