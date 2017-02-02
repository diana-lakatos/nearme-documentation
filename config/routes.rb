# frozen_string_literal: true
DesksnearMe::Application.routes.draw do
  # favicon for scraping
  get '/favicon.ico', to: 'favicon#show'

  get '/test_endpoint', to: 'webhooks/base#test'
  match '/auth/:provider/callback' => 'authentications#create', via: [:get, :post]

  namespace :v1, defaults: { format: 'json' } do
    resource :authentication, only: [:create]
    post 'authentication/:provider', to: 'authentications#social'

    resource :registration, only: [:create]

    get 'profile', to: 'profile#show'
    match 'profile', to: 'profile#update', via: [:put, :patch]
    post 'profile/avatar/:filename', to: 'profile#upload_avatar'
    delete 'profile/avatar', to: 'profile#destroy_avatar'

    get 'iplookup', to: 'iplookup#index'

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

    get 'organizations', to: 'organizations#index'
  end

  scope '(:language)', language: /[a-z]{2}/, defaults: { language: nil } do
    # Legacy pages redirect. Can be removed in Feb 16th. The redirect matches the route below.
    get '/pages/:slug(.:format)', to: 'pages#redirect'

    get '/transactable_types/:transactable_type_id/locations/:location_id/listings/:id', to: 'listings#show', as: 'transactable_type_location_listing', constraints: Constraints::TransactableTypeConstraints.new
    get '/:transactable_type_id/locations/:location_id/listings/:id', to: 'listings#show', as: 'short_transactable_type_location_listing', constraints: Constraints::TransactableTypeConstraints.new
    get '/:transactable_type_id/:location_id/listings/:id', to: 'listings#show', as: 'short_transactable_type_short_location_listing', constraints: Constraints::TransactableTypeConstraints.new
    # making (:id) optional for now even though it's required for legacy urls in a format of locations/:location_id
    get '/locations/:location_id/(:id)', to: 'listings#show', as: 'location'
    get '/locations/:location_id/listings/:id', to: 'listings#show', as: 'location_listing'

    resources :listings, only: [:show] do
      resources :orders, controller: 'listings/orders' do
        collection do
          post :store_order
        end
      end

      member do
        get :ask_a_question
        get :occurrences
        get :booking_module
      end

      resource :social_share, only: [:new], controller: 'listings/social_share'

      resources :recurring_bookings, only: [:create, :update], controller: 'listings/recurring_bookings' do
        collection do
          post :review
          post :store_recurring_booking_request
        end

        member do
          get :booking_successful
        end
      end

      resources :tickets, only: [:new, :create], controller: 'listings/support/tickets'

      resources :reservations, only: [:create, :update], controller: 'listings/reservations' do
        collection do
          post :review
          post :address
          post :store_reservation_request
          get :hourly_availability_schedule
          get :detect_overlapping
        end

        member do
          get :remote_payment
        end
      end
    end
    get '/:transactable_type_id/:id', to: 'listings#show', as: 'short_transactable_type_listing', constraints: Constraints::TransactableTypeConstraints.new

    get 'comments/index'
    get 'comments/create'

    resources :orders, only: [:show, :index] do
      resource :checkout, controller: 'checkout' do
        get :back
        get :get_states
      end
      resource :express_checkout, controller: 'express_checkout' do
        get :return
        get :cancel
      end
    end

    namespace :cart do
      get '/', action: 'index', as: 'index'
      delete 'empty'
      delete 'clear_all/:order_id', action: 'clear_all', as: 'clear_all'
      patch 'update'
      delete 'remove/:item_id', action: 'remove', as: 'remove_product'
      get 'next/:order_id', action: 'next', as: 'next'
    end

    mount CustomAttributes::Engine, at: '/custom_attributes'

    constraints subdomain: 'setup' do
      get '/', to: 'instance_wizard#index'
      get '/new', to: 'instance_wizard#new'
      post '/new', to: 'instance_wizard#new'
      post '/create', to: 'instance_wizard#create'
    end

    root to: 'home#index'

    match '/404', to: 'errors#not_found', via: :all
    match '/422', to: 'errors#server_error', via: :all
    match '/500', to: 'errors#server_error', via: :all

    namespace :support do
      root to: 'dashboard#index'
      resources :tickets, only: [:index, :new, :create, :show] do
        resources :ticket_messages, only: [:create]
        resources :ticket_message_attachments, only: [:new, :create, :edit, :update, :destroy], controller: 'tickets/ticket_message_attachments'
      end
      resources :ticket_message_attachments, only: [:new, :create, :edit, :update, :destroy]
      resources :requests_for_quotes, only: [:index]
    end

    namespace :global_admin do
      get '/', to: 'dashboard#show'

      namespace :blog do
        get '/', to: redirect('/admin/blog/blog_posts')
        resources :blog_posts
        resource :blog_instance, only: [:edit, :update]
      end

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

      resources :instances, only: [:index, :show, :edit, :update] do
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
      resources :transactable_types, only: [] do
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

    namespace :instance_admin do
      get '/', to: 'base#index'

      namespace :analytics do
        get '/', to: 'base#index'
        resource :overview, only: [:show], controller: 'overview'
        resource :sales, only: [:show]
        resource :profiles, only: [:show]
        resources :logs, only: [:index, :destroy, :show]
      end

      namespace :reports do
        resources :transactables do
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

        resources :users do
          collection do
            get :download_report
          end
        end
      end

      namespace :settings do
        get '/', to: 'base#index'
        resources :domains do
          resource :hosted_zone do
            resources :resource_records
          end
        end
        resources :aws_certificates
        resources :aws_certificate_confirmations, only: [:create]
        resources :certificate_uploads, only: [:new, :create, :destroy]

        resources :api_keys, only: [:index, :create, :destroy]
        resource :hidden_controls, only: [:show, :update], controller: 'hidden_controls'
        resource :certificate_request, only: [:new, :create]
        resource :configuration, only: [:show, :update], controller: 'configuration' do
          collection do
            post :lock
          end
        end
        resource :integrations, only: [:show, :update], controller: 'integrations' do
          collection do
            post :countries
            post :payment_gateways
            post :country_payment_gateway
            get :country_payment_gateways
            match :create_or_update_payment_gateway, via: [:post, :put, :patch]
          end
        end
        resource :locations, only: [:show, :update], controller: 'locations'
        resources :location_types, only: [:index, :create, :update, :destroy_modal, :destroy] do
          get 'destroy_modal', on: :member
        end

        namespace :shippings do
          resources :shipping_providers
          resources :deliveries
        end

        resources :payments
        resources :payment_gateways, controller: 'payments/payment_gateways', except: [:show]
        resources :tax_regions do
          collection do
            put :update_settings
          end
        end
        resource :translations, only: [:show, :update], controller: 'translations'
        resource :cancellation_policy, only: [:show, :update], controller: 'cancellation_policy'
        resource :documents_upload, except: [:index, :destroy], controller: 'documents_upload'
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

      namespace :custom_templates do
        concern :versionable do
          member do
            get :versions
            get 'show_version/:version_id', action: :show_version
            get 'rollback_version/:version_id', action: :rollback
          end
        end

        resources :custom_themes do
          resources :instance_views, controller: 'custom_themes/instance_views', concerns: :versionable
          resources :custom_theme_assets, controller: 'custom_themes/custom_theme_assets', concerns: :versionable
        end
      end

      namespace :theme do
        get '/', to: 'base#index'
        resource :info, only: [:show, :update], controller: 'info'
        resource :design, only: [:show, :update], controller: 'design' do
          member do
            delete 'delete_font'
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
        resources :graph_queries, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :file_uploads do
          collection do
            get :search
          end
        end

        resources :photo_upload_versions do
          collection do
            post :regenerate_versions
          end
        end

        resources :default_images
      end

      namespace :manage do
        get '/', to: 'base#index'

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

        resources :instance_profile_types, except: [:show] do
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

        resource :location, only: 'show', controller: 'location' do
        end

        resources :instances do
          resources :form_components, controller: 'instances/form_components' do
            member do
              patch :update_rank
            end
            collection do
              post :create_as_copy
            end
          end
        end

        resources :custom_model_types do
          resources :custom_attributes, controller: 'custom_model_types/custom_attributes'
        end

        resources :reservation_types do
          resources :custom_attributes, controller: 'reservation_types/custom_attributes'
          resources :form_components, controller: 'reservation_types/form_components' do
            member do
              patch :update_rank
            end
            collection do
              post :create_as_copy
            end
          end
        end

        resources :transactable_types do
          get :search_settings, on: :member
          put :change_state, on: :member
          resources :custom_attributes, controller: 'transactable_types/custom_attributes'
          resources :custom_validators, controller: 'transactable_types/custom_validators'
          resources :data_uploads, only: %i(new index create show), controller: 'transactable_types/data_uploads' do
            collection do
              get :download_csv_template
              get :download_current_data
            end
          end
          resources :form_components, controller: 'transactable_types/form_components', except: [:show] do
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
          resources :user_profiles, only: [] do
            member do
              post :approve
            end
          end
        end

        resources :merchant_accounts do
          member do
            get :void
            get :pending
          end
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

        resources :partners
        resources :payments, only: [:index, :show, :update] do
          member do
            put :reload
          end
        end
        resources :orders, only: [:index, :show] do
          member do
            post :generate_next_period
          end
        end
        resources :webhooks, only: [:index, :show, :destroy] do
          member do
            post :retry
          end
        end

        resources :admins, only: [:index, :create]
        namespace :admins do
          resources :instance_admins, only: [:create, :update, :destroy, :index]
          resources :instance_admin_roles, only: [:create, :update, :destroy, :index]
        end

        resources :email_layout_templates, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :email_templates, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :sms_templates, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :waiver_agreement_templates, only: [:index, :create, :update, :destroy]

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

        resources :inappropriate_reports
      end

      namespace :manage_blog do
        get '/', to: 'base#index'
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
        get '/', to: 'base#index'
        resources :transactable_types do
          resources :custom_attributes, controller: 'transactable_types/custom_attributes'
          resources :custom_validators, controller: 'transactable_types/custom_validators'
          resources :categories, except: [:new, :show], controller: 'transactable_types/categories' do
            member do
              get :jstree
            end
          end
          resources :form_components, controller: 'transactable_types/form_components', except: [:show] do
            member do
              patch :update_rank
            end
            collection do
              post :create_as_copy
            end
          end
        end
        resources :topics

        resources :spam_reports, only: [:index, :show, :destroy] do
          member do
            post :ignore
          end
          collection do
            delete :cancel
          end
        end

        resources :projects, only: [:index, :destroy, :edit, :update] do
          post :restore, on: :member
        end
      end

      namespace :groups do
        resources :group_types do
          resources :custom_validators, controller: 'group_types/custom_validators'
        end

        resources :groups, only: [:index, :edit, :update, :destroy] do
          post :restore, on: :member
        end
      end
    end

    resources :inappropriate_reports

    resources :blog_posts, path: 'blog', only: [:index, :show], controller: 'blog/blog_posts'

    resources :reviews, only: [:index]

    resources :topics, only: [:show]

    resources :comments do
      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :spam_reports, only: [:create, :destroy] do
          collection do
            delete :cancel
          end
        end
      end
    end

    resources :groups, only: [:show] do
      resources :group_members, only: [:create, :destroy] do
        patch :accept, on: :member
      end
    end

    resources :listings, only: [] do
      resources :transactable_collaborators, only: [:create, :destroy] do
        member do
          get :accept
        end
      end
      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :spam_reports, only: [:create, :destroy] do
          collection do
            delete :cancel
          end
        end
      end
    end

    resources :onboarding

    get '/auth/failure', to: 'authentications#failure'
    devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }
    devise_scope :user do
      post 'users/avatar', to: 'registrations#avatar', as: 'avatar'
      get 'users/status', to: 'registrations#status', as: 'status'
      get 'users/edit_avatar', to: 'registrations#edit_avatar', as: 'edit_avatar'
      match 'users/update_avatar', to: 'registrations#update_avatar', as: 'update_avatar', via: [:patch, :put]
      delete 'users/avatar', to: 'registrations#destroy_avatar', as: 'destroy_avatar'

      post 'users/cover_image', to: 'registrations#cover_image', as: 'cover_image'
      get 'users/cover_image', to: 'registrations#edit_cover_image', as: 'edit_cover_image'
      match 'users/cover_image', to: 'registrations#update_cover_image', as: 'update_cover_image', via: [:patch, :put]
      delete 'users/cover_image', to: 'registrations#destroy_cover_image', as: 'destroy_cover_image'

      get 'users/set_password', to: 'registrations#set_password', as: 'set_password'
      match 'users/update_password', to: 'registrations#update_password', as: 'update_password', via: [:patch, :put]
      get 'users/edit_notification_preferences', to: 'registrations#edit_notification_preferences', as: 'edit_notification_preferences'
      match 'users/update_notification_preferences', to: 'registrations#update_notification_preferences', as: 'update_notification_preferences', via: [:patch, :put]
      post 'users/store_geolocated_location', to: 'registrations#store_geolocated_location', as: 'store_geolocated_location'
      get 'users/', to: 'registrations#new'
      get 'users/verify/:id/:token', to: 'registrations#verify', as: 'verify_user'
      get 'users/:id', to: 'registrations#show', as: 'profile'
      get 'users/:user_id/blog', to: 'registrations/blog#index', as: 'user_blog_posts_list'
      get 'users/:user_id/blog/:id', to: 'registrations/blog#show', as: 'user_blog_post_show'
      get 'sellers/:user_id', to: 'registrations/sellers#show', as: 'seller_profile'
      get 'buyers/:user_id', to: 'registrations/buyers#show', as: 'buyer_profile'
      get 'users/unsubscribe/:signature', to: 'registrations#unsubscribe', as: 'unsubscribe'
      get 'dashboard/edit_profile', to: 'registrations#edit', as: 'dashboard_profile'
      get 'dashboard/social_accounts', to: 'registrations#social_accounts', as: 'social_accounts'
      patch 'users/:user_id/mobile_number', to: 'registrations#mobile_number', as: 'mobile_number_user'

      match 'users/store_correct_ip', to: 'sessions#store_correct_ip', as: 'store_correct_ip', via: [:patch, :put]

      get '/instance_admin/sessions/new', to: 'instance_admin/sessions#new', as: 'instance_admin_login'
      post '/instance_admin/sessions', to: 'instance_admin/sessions#create'
      delete '/instance_admin/sessions', to: 'instance_admin/sessions#destroy'
    end

    get 'users/:id/reviews_collections', to: 'user_reviews#reviews_collections', as: 'reviews_collections'

    resources :listings, :users, :reservations, :transactable_collaborators, :recurring_bookings, :offers, :delayed_reservations, only: [] do
      resources :user_messages, controller: 'dashboard/user_messages', except: [:index] do
        patch :archive
        put :archive
      end
    end

    resources :approval_request_attachments, only: %i(create destroy)

    resources :seller_attachments, only: [:show, :index]
    resources :custom_assets, only: [:show]

    namespace :dashboard do
      namespace :api do
        resources :categories do
          member do
            get :tree
            get :tree_new_ui
          end
        end
      end

      resources :deliveries do
        resources :package_labels
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
      resources :custom_images, only: [:edit, :update, :destroy]
      resource :seller, only: [:show, :edit, :update]
      resource :buyer, only: [:show, :edit, :update]

      resources :project_types do
        resources :projects do
          namespace :company do
            resources :transactable_collaborators, only: [:create, :update, :destroy]
          end
        end
      end

      resources :groups do
        get :video, on: :member
        resources :group_members, only: [:index, :create, :destroy, :approve, :moderate] do
          patch :approve, on: :member
          patch :moderate, on: :member
        end
      end

      resources :payment_gateways, only: [] do
        resources :credit_cards, only: [:new, :create, :index, :destroy], controller: 'payment_gateways/credit_cards'
      end
      resources :bank_accounts

      namespace :company do
        resource :analytics do
          get ':chart_type', to: :show
        end

        resources :order_items

        # TODO: move orders_received scope to company/orders scope
        resources :orders do
          resources :payment_subscriptions
          resources :order_items do
            member do
              post :approve
              put :reject
              get :rejection_form
            end
          end
        end

        # TODO: move orders_received scoep to company/orders scope
        # plese add new controllers in orders scope
        resources :orders_received do
          member do
            post :accept
            post :confirm
            post :complete
            post :cancel
            post :archive
            patch :reject
            put :reject
            get :rejection_form
            get :confirmation_form
          end

          resources :payments do
            member do
              post :refund
              post :capture
              post :mark_as_paid
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
            get :complete_reservation
            patch :submit_complete_reservation
            get :reservation_completed
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

        resources :user_auctions do
          member do
            get :reject
            get :approve
            get :details
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
            get :required_modal
          end
        end
        resources :merchant_accounts do
          resources :paypal_agreements
          member do
            get :boarding_complete
          end
        end

        resources :transactable_collaborators do
          post :create_bulk, on: :collection
        end

        get 'offers', controller: 'transactables', action: :orders, with_orders: true

        resources :transactables do
          member do
            get :enable
            get :disable
            get :cancel
          end

          resources :transactable_collaborators
        end

        resources :transactable_types do
          resources :transactables, controller: 'transactable_types/transactables' do
            member do
              get :enable
              get :disable
              get :cancel
            end

            resources :transactable_collaborators
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
        resources :users, except: [:edit, :update] do
          member do
            get :collaborations_for_current_user
          end

          get :bulk_collaborations_for_current_user, on: :collection
        end
        resources :waiver_agreement_templates, only: [:index, :edit, :new, :update, :create, :destroy]

        resources :white_labels, only: [:edit, :update, :show] do
          member do
            delete 'destroy_image/:image', action: :destroy_image, as: 'destroy_theme_image'
            get 'edit_image/:image', action: :edit_image, as: 'edit_theme_image'
            match 'update_image/:image', action: :update_image, as: 'update_theme_image', via: [:post, :put]
            match 'upload_image/:image', action: :upload_image, as: 'upload_theme_image', via: [:post, :put]
          end
        end
        namespace :support do
          resources :tickets, only: [:show, :index] do
            resources :ticket_messages, only: [:create]
            resources :ticket_message_attachments, only: [:create, :edit, :update, :destroy]
          end
        end
      end # ends company namespace

      resources :transactable_types, only: [:index] do
        resources :transactables, only: [:new, :create]
      end

      resources :transactables, except: [:new, :create]
      resources :transactable_collaborators

      resources :shipping_profiles do
        collection do
          get :get_shipping_profiles_list
        end
      end

      resource :notification_preferences, only: [:edit, :update]

      resource :click_to_call_preferences, only: [:edit, :update]

      resources :companies, only: [:edit, :update, :show]

      resources :images
      resources :order_items
      resources :orders do
        resources :order_items do
          member do
            post :approve
            put :reject
            get :rejection_form
          end
        end
        member do
          get :success
          post :generate_next_period
          post :enquirer_cancel
          post :approve
        end
      end

      resources :photos, only: [:create, :destroy, :edit, :update]
      resources :seller_attachments, only: %i(new create update destroy)
      resources :reviews, only: [:index, :create, :update, :destroy] do
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
      resources :user_reservations, except: [:update, :destroy, :show] do
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

        resources :payments, only: [:edit, :update], controller: 'user_reservations/payments' do
          member do
            post :approve
            put :reject
            get :rejection_form
          end
        end
      end

      resources :user_recurring_bookings, except: [:destroy] do
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

        resources :payment_subscriptions, only: [:edit, :update], controller: 'user_recurring_bookings/payment_subscriptions'
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
    end # end /dashboard namespace

    resources :featured_items, only: :index

    resources :users do
      resources :tags, only: :index
    end

    resources :reservations do
      resources :payment_notifications, controller: 'reservations/payment_notifications'
    end

    get '/dashboard', controller: 'dashboard/dashboard', action: 'index'

    get '/search/categories', to: 'search#categories'
    get '/search/(:search_type)', to: 'search#index', as: :search

    resources :authentications, only: [:create, :destroy] do
      collection do
        post :clear # Clear authentications stored in session
      end
    end

    post '/follow', to: 'activity_feed#follow', as: :follow
    delete '/unfollow', to: 'activity_feed#unfollow', as: :unfollow

    get '/see_more_activity_feed', to: 'activity_feed#activity_feed', as: :see_more_activity_feed
    get '/see_more_following_people', to: 'activity_feed#following_people', as: :see_more_following_people
    get '/see_more_following_transactables', to: 'activity_feed#following_transactables', as: :see_more_following_transactables
    get '/see_more_following_topics', to: 'activity_feed#following_topics', as: :see_more_following_topics
    get '/see_more_followers', to: 'activity_feed#followers', as: :see_more_followers
    get '/see_more_transactables', to: 'activity_feed#transactables', as: :see_more_transactables
    get '/see_more_collaborators', to: 'activity_feed#collaborators', as: :see_more_collaborators
    get '/see_more_members', to: 'activity_feed#members', as: :see_more_members
    get '/see_more_groups', to: 'activity_feed#groups', as: :see_more_groups

    resources :user_status_updates, only: [:create, :update, :destroy]

    resources :spam_reports, only: [:index]

    resources :activity_feed_event do
      resources :spam_reports, only: [:create, :destroy] do
        collection do
          delete :cancel
        end
      end

      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :spam_reports, only: [:create, :destroy] do
          collection do
            delete :cancel
          end
        end
      end
    end

    resources :activity_feed_subscription, only: [] do
      resources :comments, only: [:update, :create, :index, :destroy] do
        resources :comment_spam_reports, only: [:create, :destroy]
      end
    end

    resources :transactable_types do
      get '/new', as: 'new_space_wizard', controller: 'transactable_types/space_wizard', action: 'new'
      get '/list', as: 'space_wizard_list', controller: 'transactable_types/space_wizard', action: 'list'
      post '/list', controller: 'transactable_types/space_wizard', action: 'submit_listing'
      post '/submit_item', controller: 'transactable_types/space_wizard', action: 'submit_item'
    end

    resources :project_types do
      resources :project_wizard, only: [:new, :create], controller: 'project_types/project_wizard'
      resources :categories, only: [:index, :show], controller: 'transactable_types/categories'
    end

    scope '/space' do
      get '/new' => 'space_wizard#new', :as => 'new_space_wizard'
      get '/list' => 'space_wizard#list', :as => 'space_wizard_list'
      post '/list' => 'space_wizard#submit_listing'
      match '/list' => 'space_wizard#submit_listing', via: [:put, :patch]
      match '/photo' => 'space_wizard#submit_photo', :as => 'space_wizard_photo', via: [:post, :put]
      delete '/photo/:id' => 'space_wizard#destroy_photo', :as => 'destroy_space_wizard_photo'
    end

    resources :waiver_agreement_templates, only: [:show]

    namespace :api do
      concern :versionable do
        member do
          get :versions
          get 'show_version/:version_id', action: :show_version
          get 'rollback_version/:version_id', action: :rollback
        end
      end

      scope module: :v2, constraints: Constraints::ApiConstraints.new(version: 2, default: false) do
        resources :sessions, only: [:create]
        resources :users, only: [:create, :show]
        resource :space_wizard, only: [:create]
        resources :transactables, only: [:index]
        resources :reverse_proxy_links, only: [:index, :create]
        resources :instance_views, only: [:show, :create, :update, :destroy], concerns: :versionable

        resources :themes, as: 'custom_themes', controller: 'custom_themes', only: [:show, :create, :update, :destroy] do
          resources :instance_views, controller: 'custom_themes/instance_views', concerns: :versionable
          resources :assets, as: 'custom_theme_assets', controller: 'custom_themes/custom_theme_assets', concerns: :versionable
        end
      end

      scope module: :v3, constraints: Constraints::ApiConstraints.new(version: 3, default: true) do
        resources :sessions, only: [:create]
        resources :users, only: [:create, :show]
        resource :space_wizard, only: [:create]
        resources :transactables, only: [:index]
        resources :photos, only: [:create]
        resources :reverse_proxy_links, only: [:index, :create]
        resources :wish_list_items, only: [:index, :create, :destroy]
        resources :transactable_collaborators, only: [:create, :destroy] do
          member do
            put :accept
          end
        end
        resources :instances, only: [:index, :create]

        resources :instance_views, only: [:show, :create, :update, :destroy], concerns: :versionable

        resources :themes, as: 'custom_themes', controller: 'custom_themes', only: [:show, :create, :update, :destroy] do
          resources :instance_views, controller: 'custom_themes/instance_views', concerns: :versionable
          resources :assets, as: 'custom_theme_assets', controller: 'custom_themes/custom_theme_assets', concerns: :versionable
        end
      end
      resources :graph, via: [:post, :options]
    end

    resources :users do
      resources :communications, only: [:create, :destroy] do
        collection do
          get 'verified'
          get 'verified_success'
        end
      end
      resources :phone_calls, only: [:new, :create, :destroy]
    end

    get '/:slug/(:slug2)/(:slug3)(.:format)', to: 'pages#show', as: :pages, constraints: Constraints::PageConstraints.new

    get '/w-hotels-desks-near-me', to: 'locations#w_hotels', as: :w_hotels_location
    get '/W-hotels-desks-near-me', to: 'locations#w_hotels'

    get '/rent-accounting-desks', to: 'locations#vertical_accounting'
    get '/rent-legal-desks', to: 'locations#vertical_law'
    get '/rent-hairdressing-booth-stations', to: redirect(subdomain: 'rent-salon-space', path: '/')
    get '/rent-design-desks', to: 'locations#vertical_design'

    get '/sitemap.xml', to: 'seo#sitemap', format: 'xml', as: :sitemap
    get '/robots.txt', to: 'seo#robots', format: 'txt', as: :robots
  end

  namespace :webhooks do
    resource :profile, only: [] do
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

    post 'stripe', to: 'stripe#webhook'
    post 'stripe_connect', to: 'stripe#webhook'

    resource :communications, only: [:status] do
      post :status, on: :collection
    end

    resources :phone_calls, only: [:status, :connect] do
      post :status, on: :collection
      get :connect, on: :collection
    end
  end

  mount Ckeditor::Engine => '/ckeditor'

  get '/dynamic_theme/:stylesheet-:theme_id-:updated_at.css', to: 'dynamic_themes#show', as: :dynamic_theme, format: 'css', constraints: { stylesheet: /(application|dashboard)/ }

  namespace :admin do
    get '/register', to: 'pages#register'
    get '/login', to: 'pages#login'

    get '/ui_settings', to: 'ui_settings#index', as: :get_all_ui_settings
    get '/ui_settings/get/:id', to: 'ui_settings#get', as: :get_ui_setting
    patch '/ui_settings', to: 'ui_settings#set', as: :set_ui_setting

    get '/configure', to: 'configure#index'

    # get '/:page', to: 'pages#show'

    # get '/dialog/:id', to: 'dialogs#show', as: 'dialog'

    resources :help_contents, only: [:edit, :update, :show]

    namespace :assets do
      get '/new', to: 'transactable_type#new', as: :new
      post '/', to: 'transactable_type#create'

      delete '/:slug', to: 'transactable_type#destroy', as: :asset

      get '/:slug/general_settings', to: 'general_settings#edit', as: :general_settings
      patch '/:slug/general_settings', to: 'general_settings#update'
      put '/:slug/general_settings', to: 'general_settings#update'
    end

    namespace :advanced do
      get '/', to: 'base#index'
      resources :domains do
        resource :hosted_zone
      end
      resources :graph_queries
    end

    namespace :design do
      get '/', to: 'base#index'

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

      resources :themes, controller: 'custom_themes' do
        resources :instance_views, controller: 'custom_themes/instance_views', concerns: :versionable
        resources :assets, controller: 'custom_themes/custom_theme_assets', concerns: :versionable
      end

      resources :content_holders, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :liquid_views, only: [:index, :new, :create, :edit, :update, :destroy], concerns: :versionable
      resources :file_uploads do
        collection do
          get :search
        end
      end

      get '/files', to: 'files#index'
    end

    get '/', to: 'configure#index'
  end
end
