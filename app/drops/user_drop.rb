# frozen_string_literal: true
class UserDrop < BaseDrop
  include ActionView::Helpers::AssetUrlHelper
  include CategoriesHelper
  include ClickToCallButtonHelper
  include ReservationsHelper

  # id
  #   unique id of the user
  # name
  #   full name for this user
  # friends
  #   array of friends for this user
  # friends_know_host_of
  #   returns an array containing the users that are followed by the administrator passed as
  #   a parameter and that are also followed by this user
  # mutual_friends
  #   returns an array containing users that are followed by this user and that also follow
  #   him back
  # know_host_of
  #   returns an array of user objects containing users that are followed by the administrator
  #   of the listing passed as a parameter
  # first_name
  #   first name of this user
  # middle_name
  #   middle name of this user
  # last_name
  #   last name of this user
  # email
  #   email for this user
  # full_mobile_number
  #   mobile number for this user
  # administered_locations_pageviews_30_day_total
  #   total number of impressions for the locations of the first company created by this user
  #   if it exists, otherwise for the administered locations
  # country_name
  #   user country name
  # phone
  #   user phone number including country code
  # current_address
  #   current address of the user
  # has_published_posts?
  #   returns true if user has any published posts
  # seller_properties
  #   returns an array of custom attributes values for seller profile
  # buyer_properties
  #   returns an array of custom attributes values for buyer profile
  # seller_average_rating
  #   average rating of this user as a seller
  # default_wish_list
  #   return default wish list
  # external_id
  #   id of a user in a third party system, used by bulk upload
  # tags
  #   user tags
  # registration_completed?
  #   returns string / nil depending on first company completion date
  # has_company?
  #   returns whether user has company
  # company_id
  #   returns id of first user company
  # reservations_count
  #   returns number of reservations
  # unconfirmed_received_orders_count
  #   returns number of unconfirmed orders
  # instance_admin?
  #   returns true if current user is an instance admin
  delegate :id, :name, :friends, :friends_know_host_of, :mutual_friends, :know_host_of,
           :with_mutual_friendship_source, :first_name, :middle_name, :last_name, :reservations_count,
           :email, :full_mobile_number, :administered_locations_pageviews_30_day_total, :blog,
           :country_name, :phone, :current_address, :is_trusted?, :reservations,
           :has_published_posts?, :seller_properties, :buyer_properties, :name_with_affiliation,
           :external_id, :seller_average_rating, :default_wish_list, :buyer_profile, :seller_profile,
           :tags, :has_friends, :transactables_count, :completed_transactables_count, :has_active_credit_cards?,
           :communication, :created_at, :has_buyer_profile?, :has_seller_profile?, :default_company,
           :company_name, :instance_admins_metadata, :total_reviews_count, :companies, :instance_admin?,
           to: :source

  def class_name
    'User'
  end

  def wish_list_path
    routes.wish_list_path(id: @source.id, wishlistable_type: 'User')
  end

  def wish_list_bulk_path
    routes.bulk_show_wish_lists_path
  end

  # string containing the location of the user making use of the various fields
  # the user has filled in for his profile
  def display_location
    @source.decorate.display_location
  end

  # plural of the user's name
  delegate :pluralize, to: :name, prefix: true

  # plural of the user's first name
  delegate :pluralize, to: :first_name, prefix: true

  # returns true if the profile of the user has been marked as public
  def public_profile?
    @source.public_profile
  end

  # returns true if user is authenticated with facebook
  def facebook_connections
    @source.decorate.social_connections_for('facebook').present?
  end

  # returns true if user is authenticated with linkedin
  def linkedin_connections
    @source.decorate.social_connections_for('linkedin').present?
  end

  # returns true if user is authenticated with twitter
  def twitter_connections
    @source.decorate.social_connections_for('twitter').present?
  end

  # path to the search section in the application
  def search_url
    routes.search_path
  end

  # path to the search section in the application, with tracking
  def search_url_with_tracking
    routes.search_path
  end

  # returns true if the city where the user books items is present
  def reservation_city?
    @source.orders.reservations.first.listing.location[:city].present?
  end

  # the city where the user books items
  def reservation_city
    @source.orders.reservations.first.listing.location.city
  end

  # string identifying the location where the user books items
  # this method may be used if reservation_city is not present
  def reservation_name
    listing_location = @source.orders.reservations.first.listing.location
    reservation_city? ? listing_location.city : listing_location.name
  end

  # url to the app wizard for adding a new listing to the system
  def space_wizard_list_path
    routes.new_user_session_path(return_to: routes.space_wizard_list_path)
  end

  # url to the app wizard for adding a new listing to the system, with tracking
  def space_wizard_list_url_with_tracking
    routes.space_wizard_list_path(token_key => @source.try(:temporary_token))
  end

  def manage_locations_url
    routes.dashboard_company_transactable_types_path
  end

  def manage_locations_url_with_tracking
    routes.dashboard_company_transactable_types_path
  end

  def manage_locations_url_with_tracking_and_token
    routes.dashboard_company_transactable_types_path(token_key => @source.try(:temporary_token))
  end

  # url to the section in the app for editing a user's profile
  def edit_profile_path
    routes.dashboard_profile_path
  end

  # url to the section in the app for editing a user's profile
  def edit_user_registration_url(_with_token = false)
    routes.edit_user_registration_path(token_key => @source.try(:temporary_token))
  end

  # url to the section in the app for editing a user's profile, with authentication token
  def edit_user_registration_url_with_token
    routes.edit_user_registration_path(token_key => @source.try(:temporary_token))
  end

  # url to the section in the app for editing a user's profile, with authentication token and tracking
  def edit_user_registration_url_with_token_and_tracking
    routes.edit_user_registration_path(token_key => @source.try(:temporary_token))
  end

  # url to reset password
  def reset_password_url
    routes.edit_user_password_url(reset_password_token: @source.try(:reset_password_token))
  end

  # url to a user's public profile
  def user_profile_url
    routes.profile_path(@source.slug)
  end

  # url to reviews in user's public profile
  def reviews_user_profile_url
    routes.profile_path(@source.slug, tab: 'reviews')
  end

  # url to services in user's public profile
  def services_user_profile_url
    routes.profile_path(@source.slug, tab: 'services')
  end

  # url to blog posts in user's public profile
  def blog_posts_user_profile_url
    routes.profile_path(@source.slug, tab: 'blog_posts')
  end

  # url for seller/buyer/default user profile
  def profile_url_for_search
    case @context['transactable_type'].profile_type
    when UserProfile::SELLER
      routes.seller_profile_path(@source.slug)
    when UserProfile::BUYER
      routes.buyer_profile_path(@source.slug)
    else
      routes.profile_path(@source.slug)
    end
  end

  def listings
    @source.listings
  end

  def show_services_tab?
    !hide_tab?('services') && @context['listings']
  end

  def show_blog_tab?
    PlatformContext.current.instance.blogging_enabled?(@source) && @source.blog.try(:enabled?) && !hide_tab?('blog_posts')
  end

  def published_posts
    @source.published_blogs.limit(5)
  end

  def reviews_collection_path
    routes.reviews_collections_path(@source)
  end

  def profile_url
    urlify(routes.profile_path(@source.slug))
  end

  def projects_profile_url_with_token
    urlify(routes.profile_path(@source.slug, token_key => @source.try(:temporary_token), anchor: :projects))
  end

  def groups_profile_url_with_token
    urlify(routes.profile_path(@source.slug, token_key => @source.try(:temporary_token), anchor: :groups))
  end

  # url to the section in the application where a user can change his password
  def set_password_url_with_token
    routes.set_password_path(token_key => @source.try(:temporary_token))
  end

  # url to the section in the application where a user can change his password
  # with authentication token and tracking
  def set_password_url_with_token_and_tracking
    routes.set_password_path(token_key => @source.try(:temporary_token))
  end

  # url for verifying (confirming) a user's email
  def verify_user_url
    routes.verify_user_path(@source.id, @source.email_verification_token)
  end

  # url for verifying (confirming) a user's email
  def bookings_dashboard_url
    routes.dashboard_orders_path
  end

  # returns true if the email address is verified
  def is_email_verified?
    @source.verified_at.present?
  end

  # url to the section in the application for managing a user's own bookings, with tracking
  def bookings_dashboard_url_with_tracking
    routes.dashboard_orders_path
  end

  # url to the section in the application for managing a user's own bookings, with authentication
  # token
  def bookings_dashboard_url_with_token
    routes.dashboard_orders_path(token_key => @source.try(:temporary_token))
  end

  # url to the section in the application for managing a user's own bookings, with authentication
  # token, and tracking
  def bookings_dashboard_url_with_tracking_and_token
    routes.dashboard_orders_path(token_key => @source.try(:temporary_token))
  end

  # listings in and around a user's location, limited to a 100 km radius and a maximum of 3 results
  def listings_in_near
    @source.listings_in_near(3, 100, true)
  end

  # the user's custom properties list
  def properties
    @source.properties
  end

  # url to the "big" version of a user's avatar image
  def avatar_url_big
    ActionController::Base.helpers.asset_url(@source.avatar_url(:big))
  end

  # url to the "thumb" version of a user's avatar image
  def avatar_url_thumb
    ActionController::Base.helpers.asset_url(@source.avatar_url(:thumb))
  end

  def avatar_url_bigger
    ActionController::Base.helpers.asset_url(@source.avatar_url(:bigger))
  end

  # url to a user's public profile
  def profile_path
    routes.profile_path(@source)
  end

  # url to the section in the application for sending a message to this user using the
  # marketplace's internal messaging system
  def user_message_path
    routes.new_user_user_message_path(user_id: @source.slug)
  end

  def user_blog_posts_list_path
    routes.user_blog_posts_list_path(@source)
  end

  def has_active_blog?
    PlatformContext.current.instance.blogging_enabled?(@source) && @source.blog.try(:enabled?)
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name', "children" => [<collection of chosen values] } }
  def categories
    @categories = build_categories_hash_for_object(@source, Category.users.roots.includes(:children)) if @categories.nil?
    @categories
  end

  def buyer_categories
    if @categories.nil?
      @categories = build_categories_hash_for_object(@source.buyer_profile, Category.buyers.roots.includes(:children))
    end
    @categories
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name>', "children" => 'comma separated children' } }
  def formatted_categories
    build_formatted_categories(@source.categories)
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name>', "children" => [array with children] } }
  def formatted_buyer_categories
    build_categories_to_array(@source.buyer_profile.categories) if @source.buyer_profile
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name>', "children" => [array with children] } }
  def formatted_seller_categories
    build_categories_to_array(@source.seller_profile.categories) if @source.seller_profile
  end

  # User's current address
  def address
    @source.current_address.presence || @source.locations.first.try(:location_address)
  end

  # Returns true if currently logged user is this user
  def is_current_user?
    @source.id == @context['current_user'].try(:id)
  end

  # Returns an array of custom attributes for seller profile
  def seller_attributes
    @source.seller_profile.instance_profile_type.custom_attributes.public_display
  end

  # Returns an array of custom attributes for buyer profile
  def buyer_attributes
    @source.buyer_profile.instance_profile_type.custom_attributes.public_display
  end

  # Returns an array of custom attributes for default profile
  def default_attributes
    @source.default_profile.instance_profile_type.custom_attributes.public_display
  end

  # Returns an array of custom attributes for default and seller profile
  def default_and_seller_attributes
    default_attributes + seller_attributes
  end

  # Returns an array of custom attributes for default and buyer profile
  def default_and_buyer_attributes
    default_attributes + buyer_attributes
  end

  # Returns an array of custom attributes values for all user profiles
  def all_properties
    @all_properties ||= @source.default_properties.to_h.merge(@source.seller_properties.to_h.merge(@source.buyer_properties.to_h))
  end

  # Is the user "twitter connected" to the site
  def is_twitter_connected
    social_connections.where(provider: 'twitter').exists?
  end

  # Is the user "facebook connected" to the site
  def is_facebook_connected
    social_connections.where(provider: 'facebook').exists?
  end

  # Is the user "linkedin connected" to the site
  def is_linkedin_connected
    social_connections.where(provider: 'linkedin').exists?
  end

  def member_since
    I18n.l(@source.created_at.to_date, format: :short)
  end

  def completed_host_reservations_count
    @source.listing_orders.reservations.reviewable.count
  end

  # Click to call button
  def click_to_call_button
    build_click_to_call_button_for_user(@source)
  end

  # Click to call button with just the first name
  def click_to_call_button_first_name
    build_click_to_call_button_for_user(@source, first_name: true)
  end

  # whether or not the user has a buyer profile set up
  def has_buyer_profile?
    @source.buyer_profile.present? && @source.buyer_profile.persisted?
  end

  # whether or not the user has a seller profile set up
  def has_seller_profile?
    @source.seller_profile.present? && @source.seller_profile.persisted?
  end

  # whether the user only has a buyer profile
  # implemented to make things easier as Liquid does not
  # have a not operator
  def only_buyer_profile?
    has_buyer_profile? && !has_seller_profile?
  end

  # whether the user only has a seller profile
  # implemented to make things easier as Liquid does not
  # have a not operator
  def only_seller_profile?
    !has_buyer_profile? && has_seller_profile?
  end

  def has_verified_merchant_account
    @source.companies.first.try(:merchant_accounts).try(:any?, &:verified?)
  end

  def has_pending_transactables?
    pending_transactables.any?
  end

  def completed_transactables_count
    @source.created_listings.with_state(:completed).count
  end

  def pending_transactables_for_current_user
    Transactable.where(creator_id: @context['current_user'].id).with_state(:pending)
                .joins("LEFT Outer JOIN transactable_collaborators tc on
      tc.transactable_id = transactables.id and tc.user_id = #{@source.id} and
      tc.deleted_at is NULL")
  end

  def pending_transactables
    pending_transactables_for_current_user.where('tc.id is NULL')
  end

  def pending_collaborated_transactables
    pending_transactables_for_current_user.where('tc.id is NOT NULL')
  end

  def unconfirmed_received_orders_count
    @unconfirmed_received_orders_count ||= @source.listing_orders.unconfirmed.count
  end

  def has_company?
    @source.companies.present?
  end

  def company_id
    has_company? && @source.companies.first.id
  end

  def registration_completed?
    !!@source.registration_completed?
  end

  def reservations_count
    count = reservations_count_for_user(@source)
    count > 0 ? count : nil
  end

  def collaborator_transactables_for_current_user
    @source.transactables_collaborated.where(creator_id: @context['current_user'].try(:id))
  end

  # has inappropriate report for user
  def inappropriate_report_path
    routes.inappropriate_report_path(id: @source.id, reportable_type: 'User')
  end

  # total count of unread messages in user inbox
  def unread_messages_count
    @source.unread_user_message_threads_count_for(PlatformContext.current.instance)
  end

  # total count of user transactables with state pending
  def pending_transactables_count
    seller_pending_transactables_count || buyer_pending_transactables_count
  end

  def seller_pending_transactables_count
    @source.transactables.with_state(:pending).count if has_seller_profile?
  end

  def buyer_pending_transactables_count
    @source.approved_transactables_collaborated.with_state(:pending).count if has_buyer_profile?
  end

  def user_menu_instance_admin_path
    users_instance_admin = '_manage_blog' if @source.instance_admins_metadata == 'blog'
    users_instance_admin = '_support_root' if @source.instance_admins_metadata == 'support'
    routes.send("instance_admin#{users_instance_admin}_path")
  end

  def show_blog_menu?
    (!platform_context_decorator.instance.split_registration? && platform_context_decorator.instance.user_blogs_enabled) ||
      (has_seller_profile? && @source.instance.lister_blogs_enabled || has_buyer_profile? && @source.instance.enquirer_blogs_enabled)
  end

  private

  def social_connections
    @social_connections_cache ||= @source.social_connections
  end
end
