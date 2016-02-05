# super hackish way to fix add_space_wizard:12 feature
require Rails.root.join('app', 'controllers', 'registrations_controller.rb') if Rails.env.test?

DesksnearMe::Application.routes.draw do

  match '/auth/:provider/callback' => 'authentications#create', via: [:get, :post]

  scope '(:language)', language: /[a-z]{2}/, defaults: { language: nil } do

    # Legacy pages redirect. Can be removed in Feb 16th. The redirect matches the route below.
    get "/pages/:slug(.:format)", to: 'pages#redirect'
    get "/transactable_types/:id/locations/:location_id/listings/:listing_id", to: 'locations#redirect'

    get 'comments/index'
    get 'comments/create'

    scope module: 'buy_sell_market' do
      resources :products, only: [:show] do
        resources :tickets, only: [:new, :create], :controller => 'support/tickets'
      end


      resources :orders, only: [:show, :index] do
        resources :checkout do
          collection do
            get 'get_states'
            get 'cancel_express_checkout'
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

    mount CustomAttributes::Engine, at: '/custom_attributes'

    mount Ckeditor::Engine => '/ckeditor'

    constraints host: 'setup.near-me.com' do
      get '/', to: 'instance_wizard#index'
      get '/new', to: 'instance_wizard#new'
      post '/new', to: 'instance_wizard#new'
      post '/create', to: 'instance_wizard#create'
    end

    root :to => "home#index"
    namespace :webhooks do
      resource :'profile', only: [] do
        collection do
          match 'create_profile', via: [:get, :post], as: :create_profile, action: :create
          match '', via: [:get, :post], as: :webhook, action: :webhook
        end
      end
      resource :braintree_marketplace, only: [] do
        collection do
          match '', via: [:get, :post], as: :webhook, action: :webhook
        end
      end

      resource :stripe_connect, only: [] do
        collection do
          match '', via: %i(get post), as: :webhook, action: :webhook
        end
      end
    end

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

      resources :platform_admins, only: [:index, :create, :destroy]

      resources :instance_creators

      resources :instances, :only => [:index, :show, :edit, :update] do
        member do
          post :lock
        end
        resources :transactable_types do
        end
        resources :partners
        resources :instance_views, only: [:index, :new, :create, :edit, :update, :destroy] do
          resources :versions, only: [:index, :show] do
            member do
              get :rollback
            end
          end
        end
      end
      resources :transactable_types, :only => [] do
        resources :custom_attributes
      end
      resources :pages

      resource :instance_reports do
        member do
          get :download_urls
        end
      end
    end

    resources :marketplace_sessions, only: [:new, :create]
    get '/wish_list/add_item', to: 'wish_list#add_item'
    get '/wish_list/remove_item', to: 'wish_list#remove_item'

    namespace :instance_admin do
      get '/', to: 'base#index'

      namespace :analytics do
        get '/', to: 'base#index'
        resource :overview, only: [:show], controller: 'overview' do
          member do
            get :products
          end
        end
        resource :sales, only: [:show]
        resource :profiles, only: [:show]
        resources :logs, only: [:index, :destroy]
      end

      namespace :reports do
        resources :listings do
          collection do
            get :download_report
          end
        end

        resources :products do
          collection do
            get :download_report
          end
        end

        resources :projects do
          collection do
            get :download_report
          end
        end

        resources :advanced_projects do
          collection do
            get :download_report
          end
        end

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
            post :country_payment_gateway
            get :country_payment_gateways
            match :create_or_update_payment_gateway, via: [:post, :put, :patch]
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
        resources :payments
        resources :payment_gateways, controller: 'payments/payment_gateways'

        resource :translations, :only => [:show, :update], :controller => 'translations'
        resource :cancellation_policy, :only => [:show, :update], :controller => 'cancellation_policy'
        resource :documents_upload, except: [:index, :destroy], :controller => 'documents_upload'
        resource :seller_attachments, only: %i(show update destroy), controller: 'seller_attachments'

        resources :locales, except: [:show], controller: 'locales' do
          member do
            get :edit_keys
            get :date_time_preferences
          end

          collection do
            get 'new_key'
            post 'create_key'
            delete 'destroy_key'
            post 'locales_settings_update'
          end
        end
      end

      resources :themes, only: [] do
        member do
          delete 'destroy_image/:image', action: :destroy_image, as: 'destroy_image'
          get 'edit_image/:image', action: :edit_image, as: 'edit_image'
          match 'update_image/:image', action: :update_image, as: 'update_image', via: [:post, :put]
          match 'upload_image/:image', action: :upload_image, as: 'upload_image', via: [:post, :put]
        end
      end

      namespace :theme do
        get '/', :to => 'base#index'
        resource :info, :only => [:show, :update], :controller => 'info'
        resource :design, :only => [:show, :update], :controller => 'design' do
          member do
            delete 'delete_font'
            get :revert_to_old_ui
            get :convert_to_new_ui
          end
        end

        concern :versionable do
          member do
            get :versions
            get 'show_version/:version_id', action: :show_version
            get 'rollback_version/:version_id', action: :rollback
          end
        end
        resources :pages, concerns: :versionable do
          member do
            delete :delete_image
          end
        end
        resource :footer, only: [:show, :create, :update], controller: 'footer', concerns: :versionable
        resource :header, only: [:show, :create, :update], controller: 'header', concerns: :versionable
        resource :user_badge, only: [:show, :create, :update], controller: 'user_badge', concerns: :versionable
        resource :homepage, only: [:show, :update], controller: 'homepage', concerns: :versionable
        resource :homepage_template, only: [:show, :create, :update], controller: 'homepage_template', concerns: :versionable
        resources :content_holders, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :liquid_views, only: [:index, :new, :create, :edit, :update, :destroy], concerns: :versionable
        resources :file_uploads do
          collection do
            get :search
          end
        end
      end

      namespace :manage do
        get '/', :to => 'base#index'

        resources :additional_charge_types, except: [:show]
        resources :projects, only: [:edit, :update]
        resources :topics, only: [:edit, :update]
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

        resources :instance_profile_types, :only => [:index, :destroy, :update] do
          collection do
            post :enable
          end
          member do
            get :search_settings
          end
          resources :custom_validators, controller: 'instance_profile_types/custom_validators'
          resources :custom_attributes, controller: 'instance_profile_types/custom_attributes'
          resources :form_components, controller: 'instance_profile_types/form_components', except: [:show] do
            member do
              patch :update_rank
            end
            collection do
              post :create_as_copy
            end
          end
        end

        resources :service_types do
          get :search_settings, on: :member
          put :change_state, on: :member
          resources :custom_attributes, controller: 'service_types/custom_attributes'
          resources :custom_validators, controller: 'service_types/custom_validators'
          resources :data_uploads, only: %i(new index create show), controller: 'service_types/data_uploads' do
            collection do
              get :download_csv_template
              get :download_current_data
            end
          end
          resources :form_components, controller: 'service_types/form_components', except: [:show] do
            member do
              patch :update_rank
            end
            collection do
              post :create_as_copy
            end
          end
        end

        resources :custom_validators

        resources :users, only: [:index, :destroy, :edit, :update] do
          post :login_as, on: :member
          post :restore, on: :member
          post :restore_session, on: :collection
          resources :user_bans, only: [:create, :index, :destroy], controller: 'users/user_bans'
        end

        resources :transfers do
          member do
            post :transferred
            post :payout
            post :not_failed
          end

          collection do
            post :generate
          end
        end
        resources :payments, only: [:index, :show]

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
        resource :search, only: [:show, :update], controller: 'search' do
          collection do
            put :sort_transactable_types
          end
          resource :elastic, only: [:show, :update], controller: 'search/elastic'
        end

        resources :categories, except: [:new, :show] do
          member do
            get :jstree
          end
        end
      end

      namespace :manage_blog do
        get '/', :to => 'base#index'
        resources :posts do
          member do
            delete :delete_image
          end
        end
        resources :user_posts
        resource :settings, only: [:edit, :update] do
          collection do
            delete :delete_image
          end
        end
      end

      namespace :buy_sell do
        get '/', :to => 'base#index'
        resource :configuration, only: [:show, :update], controller: 'configuration'
        resource :commissions, :only => [:show, :update], :controller => 'commissions'
        resources :product_types do
          get :search_settings, on: :member
          resources :custom_attributes, controller: 'product_types/custom_attributes'
          resources :custom_validators, controller: 'product_types/custom_validators'
          resources :data_uploads, only: %i(new index create show), controller: 'product_types/data_uploads' do
            collection do
              get :download_csv_template
            end
          end
          resources :form_components, controller: 'product_types/form_components', except: [:show] do
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
        resources :shipping_categories
        resources :shipping_methods
      end

      namespace :shipping_options do
        resource :providers
        resources :dimensions_templates
        resources :shipping_profiles do
          collection do
            get :get_shipping_categories_list
          end

          member do
            post :disable_category
            post :enable_category
          end
        end
      end

      namespace :support do
        root to: 'support#index'
        resources :faqs, except: [:show]
        resources :tickets, only: [:show, :update] do
          resources :ticket_messages, only: [:create]
        end
      end

      namespace :projects do
        get '/', :to => 'base#index'
        resources :project_types do
          resources :custom_attributes, controller: 'project_types/custom_attributes'
          resources :custom_validators, controller: 'project_types/custom_validators'
          resources :categories, except: [:new, :show], controller: 'project_types/categories' do
            member do
              get :jstree
            end
          end
          resources :form_components, controller: 'project_types/form_components', except: [:show] do
            member do
              patch :update_rank
            end
            collection do
              post :create_as_copy
            end
          end
        end
        resources :topics

        resources :spam_reports, only: [ :index, :show, :destroy ] do
          member do
            post :ignore
          end
        end

        resources :projects, only: [:index, :destroy, :edit, :update] do
          post :restore, on: :member
        end
      end

    end

    resources :blog_posts, path: 'blog', only: [:index, :show], controller: 'blog/blog_posts'

    resources :reviews, only: [:index]
    resources :locations, only: [] do
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

    resources :topics, only: [:show]
    resources :projects, only: [:show] do
      resources :project_collaborators, only: [:create, :destroy] do
        member do
          get :accept
        end
      end
      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :spam_reports,  only: [:create, :destroy]
      end
    end

    resources :listings, only: [] do

      member do
        get :occurrences
      end

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
          post :address
          post :store_reservation_request
          get :return_express_checkout
          get :cancel_express_checkout
        end

        member do
          get :remote_payment
        end

        get :hourly_availability_schedule, :on => :collection
      end

    end

    resources :onboarding

    get "/auth/failure", to: "authentications#failure"
    devise_for :users, :controllers => {:registrations => 'registrations', :sessions => 'sessions', :passwords => 'passwords'}
    devise_scope :user do
      post "users/avatar", :to => "registrations#avatar", :as => "avatar"
      get "users/edit_avatar", :to => "registrations#edit_avatar", :as => "edit_avatar"
      match "users/update_avatar", :to => "registrations#update_avatar", :as => "update_avatar", via: [:patch, :put]
      delete "users/avatar", :to => "registrations#destroy_avatar", :as => "destroy_avatar"

      post "users/cover_image", :to => "registrations#cover_image", :as => "cover_image"
      get "users/cover_image", :to => "registrations#edit_cover_image", :as => "edit_cover_image"
      match "users/cover_image", :to => "registrations#update_cover_image", :as => "update_cover_image", via: [:patch, :put]
      delete "users/cover_image", :to => "registrations#destroy_cover_image", :as => "destroy_cover_image"

      get "users/set_password", :to => "registrations#set_password", :as => "set_password"
      match "users/update_password", :to => "registrations#update_password", :as => "update_password", via: [:patch, :put]
      get "users/edit_notification_preferences", :to => "registrations#edit_notification_preferences", :as => "edit_notification_preferences"
      match "users/update_notification_preferences", :to => "registrations#update_notification_preferences", :as => "update_notification_preferences", via: [:patch, :put]
      post "users/store_google_analytics_id", :to => "registrations#store_google_analytics_id", :as => "store_google_analytics"
      post "users/store_geolocated_location", :to => "registrations#store_geolocated_location", :as => "store_geolocated_location"
      get "users/", :to => "registrations#new"
      get "users/verify/:id/:token", :to => "registrations#verify", :as => "verify_user"
      get "users/:id", :to => "registrations#show", :as => "profile"
      get "users/:user_id/blog", :to => "registrations/blog#index", :as => "user_blog_posts_list"
      get "users/:user_id/blog/:id", :to => "registrations/blog#show", :as => "user_blog_post_show"
      get "sellers/:user_id", :to => "registrations/sellers#show", :as => "seller_profile"
      get "buyers/:user_id", :to => "registrations/buyers#show", :as => "buyer_profile"
      get "users/unsubscribe/:signature", :to => "registrations#unsubscribe", :as => "unsubscribe"
      get "dashboard/edit_profile", :to => "registrations#edit", :as => "dashboard_profile"
      get "dashboard/social_accounts", :to => "registrations#social_accounts", :as => "social_accounts"

      match "users/store_correct_ip", :to => "sessions#store_correct_ip", :as => "store_correct_ip", via: [:patch, :put]

      get "/instance_admin/sessions/new", :to => "instance_admin/sessions#new", :as => 'instance_admin_login'
      post "/instance_admin/sessions", :to => "instance_admin/sessions#create"
      delete "/instance_admin/sessions", :to => "instance_admin/sessions#destroy"
    end

    get "users/:id/reviews_collections", :to => "user_reviews#reviews_collections", :as => "reviews_collections"

    resources :listings, :users, :reservations, :products, :recurring_bookings do
      resources :user_messages, controller: "dashboard/user_messages", except: [:index] do
        patch :archive
        put :archive
      end
    end

    resources :approval_request_attachments, only: %i(create destroy)

    resources :seller_attachments, only: :show

    namespace :dashboard do
      namespace :api do
        resources :categories do
          member do
            get :tree
            get :tree_new_ui
          end
        end
      end

      resources :api do
        collection do
          get :countries
          get :states
        end
      end

      resource :blog, controller: 'user_blog/blog', only: [:show, :edit, :update] do
        collection do
          delete :delete_image
        end
        resources :posts, controller: 'user_blog/blog_posts' do
          member do
            delete :delete_image
          end
        end
      end
      resource :seller, only: [:show, :edit, :update]
      resource :buyer, only: [:show, :edit, :update]

      resources :project_types do
        resources :projects do
          resources :project_collaborators, only: [:create, :update, :destroy]
        end
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
              post :refund
              post :capture
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
            post :mark_as_paid
            get :request_payment
          end
        end

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

        resources :locations
        resources :dimensions_templates
        resources :payment_documents do
          collection do
            get :sent_to_me
            get :uploaded_by_me
          end
        end
        resource :payouts, except: [:index, :show, :new, :create, :destroy] do
          collection do
            get :boarding_complete
          end
        end
        resources :paypal_agreements do
          get :create
        end
        resources :products
        resources :product_type do
          resources :products
          resources :data_uploads, only: %i(new create), controller: 'product_types/data_uploads' do
            collection do
              get :download_csv_template
              get :download_current_data_csv
            end
          end
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
        namespace :support do
          resources :tickets, only: [:show, :index] do
            resources :ticket_messages, only: [:create]
            resources :ticket_message_attachments, only: [:create, :edit, :update, :destroy]
          end
        end
      end #ends company namespace

      resources :shipping_categories do
        collection do
          get :get_shipping_categories_list
        end
      end

      resource :notification_preferences, only: [:edit, :update]

      resources :companies, only: [:edit, :update, :show]

      resources :images
      resources :orders, only: [:index, :show] do
        member do
          get :success
        end
      end
      resources :photos, :only => [:create, :destroy, :edit, :update]
      resources :seller_attachments, only: %i(create update destroy)
      resources :reviews, :only => [:index, :create, :update, :destroy] do
        collection do
          get :rate
          get :completed
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

      resources :user_requests_for_quotes, only: [:index, :show]
      resources :user_reservations, :except => [:update, :destroy, :show] do
        member do
          post :user_cancel
          get :export
          get :booking_successful
          get :booking_failed
          get :booking_successful_modal
          get :booking_failed_modal
          get :remote_payment
          get :remote_payment_modal
        end
        collection do
          get :upcoming
          get :archived
        end
      end

      resources :user_recurring_bookings, :except => [:destroy] do
        member do
          get :booking_successful_modal
          post :user_cancel
          get :export
          get :booking_successful
        end
        collection do
          get :active
          get :archived
        end
      end

      resources :wish_list_items, only: [:index, :destroy], path: 'favorites' do
        collection do
          delete :clear
        end
      end

      resources :saved_searches, only: %i(index create update destroy) do
        collection do
          patch :change_alerts_frequency
        end
        member do
          get :search
        end
      end

    end #end /dashboard namespace

    resources :tags, only: :index

    resources :reservations do
      resources :payment_notifications, controller: 'reservations/payment_notifications'
    end

    get '/dashboard', controller: 'dashboard/dashboard', action: 'index'

    get "/search/categories", :to => "search#categories"
    get "/search/(:search_type)", :to => "search#index", :as => :search

    resource :event_tracker, only: [:create], :controller => 'event_tracker'

    resources :authentications, :only => [:create, :destroy] do
      collection do
        post :clear # Clear authentications stored in session
      end
    end

    post "/follow", to: "activity_feed#follow", as: :follow
    delete "/unfollow", to: "activity_feed#unfollow", as: :unfollow

    get "/see_more_activity_feed", to: "activity_feed#activity_feed", as: :see_more_activity_feed
    get "/see_more_following_people", to: "activity_feed#following_people", as: :see_more_following_people
    get "/see_more_following_projects", to: "activity_feed#following_projects", as: :see_more_following_projects
    get "/see_more_following_topics", to: "activity_feed#following_topics", as: :see_more_following_topics
    get "/see_more_followers", to: "activity_feed#followers", as: :see_more_followers
    get "/see_more_projects", to: "activity_feed#projects", as: :see_more_projects
    get "/see_more_collaborators", to: "activity_feed#collaborators", as: :see_more_collaborators

    resources :user_status_updates, only: [ :create ]

    resources :activity_feed_event do
      resources :spam_reports,  only: [:create, :destroy]

      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :spam_reports,  only: [:create, :destroy]
      end
    end

    resources :activity_feed_subscription, only: [] do
      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :comment_spam_reports,  only: [:create, :destroy]
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
      resources :categories, only: [:index, :show], :controller => 'transactable_types/categories'
    end

    resources :project_types do
      resources :project_wizard, only: [:new, :create], controller: 'project_types/project_wizard'
      resources :categories, only: [:index, :show], :controller => 'transactable_types/categories'
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

    namespace :v1, :defaults => {:format => 'json'} do

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
        %w(facebook twitter linkedin).each do |social|
          resource social.to_sym, only: [:show, :update, :destroy], controller: 'social_provider', provider: social
        end
      end

      get 'amenities', to: 'amenities#index'
      get 'organizations', to: 'organizations#index'
    end

    resources :transactable_types, only: [], path: "/", constraints: Constraints::TransactableTypeConstraints.new do
      resources :locations, :only => [], path: "/" do
        member do
          get "(:listing_id)", :to => "locations#show", :as => ''
        end

        resources :listings, controller: 'locations/listings', only: [:show] do
          member do
            get :ask_a_question
          end
        end

        resource :social_share, :only => [:new], :controller => 'locations/social_share'
      end
    end

    get "/:slug(.:format)", to: 'pages#show', as: :pages, constraints: Constraints::PageConstraints.new

    # delayed_job web gui
    match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

    get "/dashboard/api", to: 'dashboard#api', as: :spree

    get "/w-hotels-desks-near-me", to: 'locations#w_hotels', as: :w_hotels_location
    get "/W-hotels-desks-near-me", to: 'locations#w_hotels'

    get "/rent-accounting-desks", to: 'locations#vertical_accounting'
    get "/rent-legal-desks", to: 'locations#vertical_law'
    get "/rent-hairdressing-booth-stations", to: redirect(subdomain: 'rent-salon-space', path: '/')
    get "/rent-design-desks", to: 'locations#vertical_design'

    get "/sitemap.xml", to: "seo#sitemap", format: "xml", as: :sitemap
    get "/robots.txt", to: "seo#robots", format: "txt", as: :robots
  end
end
