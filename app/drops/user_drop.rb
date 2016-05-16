class UserDrop < BaseDrop

  include ActionView::Helpers::AssetUrlHelper
  include CategoriesHelper
  include ClickToCallButtonHelper

  attr_reader :user

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
  delegate :id, :name, :friends, :friends_know_host_of, :mutual_friends, :know_host_of,
    :with_mutual_friendship_source, :first_name, :middle_name, :last_name,
    :email, :full_mobile_number, :administered_locations_pageviews_30_day_total, :blog,
    :country_name, :phone, :current_address, :is_trusted?, :reservations,
    :has_published_posts?, :seller_properties, :buyer_properties, :name_with_affiliation,
    :seller_average_rating, to: :user

  def initialize(user)
    @user = user.decorate
  end

  # string containing the location of the user making use of the various fields
  # the user has filled in for his profile
  def display_location
    @user.decorate.display_location
  end

  # plural of the user's name
  def name_pluralize
    name.pluralize
  end

  # plural of the user's first name
  def first_name_pluralize
    first_name.pluralize
  end

  # returns true if the profile of the user has been marked as public
  def public_profile?
    @user.public_profile
  end

  # returns true if user is authenticated with facebook
  def facebook_connections
    @user.decorate.social_connections_for('facebook').present?
  end

  # returns true if user is authenticated with linkedin
  def linkedin_connections
    @user.decorate.social_connections_for('linkedin').present?
  end

  # returns true if user is authenticated with twitter
  def twitter_connections
    @user.decorate.social_connections_for('twitter').present?
  end

  # path to the search section in the application
  def search_url
    routes.search_path
  end

  # path to the search section in the application, with tracking
  def search_url_with_tracking
    routes.search_path(track_email_event: true)
  end

  # returns true if the city where the user books items is present
  def reservation_city?
    @user.reservations.first.listing.location[:city].present?
  end

  # the city where the user books items
  def reservation_city
    @user.reservations.first.listing.location.city
  end

  # string identifying the location where the user books items
  # this method may be used if reservation_city is not present
  def reservation_name
    self.reservation_city? ? @user.reservations.first.listing.location.city : @user.reservations.first.listing.location.name
  end

  # url to the app wizard for adding a new listing to the system
  def space_wizard_list_path
    routes.new_user_session_path(:return_to => routes.space_wizard_list_path)
  end

  # url to the app wizard for adding a new listing to the system, with tracking
  def space_wizard_list_url_with_tracking
    routes.space_wizard_list_path(token_key => @user.try(:temporary_token), track_email_event: true)
  end

  def manage_locations_url
    routes.dashboard_company_transactable_types_path
  end

  def manage_locations_url_with_tracking
    routes.dashboard_company_transactable_types_path(track_email_event: true)
  end

  def manage_locations_url_with_tracking_and_token
    routes.dashboard_company_transactable_types_path(token_key => @user.try(:temporary_token), track_email_event: true)
  end

  # url to the section in the app for editing a user's profile
  def edit_profile_path
    routes.dashboard_profile_path
  end

  # url to the section in the app for editing a user's profile
  def edit_user_registration_url(with_token = false)
    routes.edit_user_registration_path(token_key => @user.try(:temporary_token))
  end

  # url to the section in the app for editing a user's profile, with authentication token
  def edit_user_registration_url_with_token
    routes.edit_user_registration_path(token_key => @user.try(:temporary_token))
  end

  # url to the section in the app for editing a user's profile, with authentication token and tracking
  def edit_user_registration_url_with_token_and_tracking
    routes.edit_user_registration_path(token_key => @user.try(:temporary_token), :track_email_event => true)
  end

  # url to reset password
  def reset_password_url
    routes.edit_user_password_url(:reset_password_token => @user.try(:reset_password_token))
  end

  # url to a user's public profile
  def user_profile_url
    routes.profile_path(@user.slug)
  end

  # url for seller/buyer/default user profile
  def profile_url_for_search
    case @context['transactable_type'].profile_type
    when UserProfile::SELLER
      routes.seller_profile_path(@user.slug)
    when UserProfile::BUYER
      routes.buyer_profile_path(@user.slug)
    else
      routes.profile_path(@user.slug)
    end
  end

  def show_products_tab?
    !hide_tab?('products') && @context['products']
  end

  def show_services_tab?
    !hide_tab?('services') && @context['listings']
  end

  def show_blog_tab?
    PlatformContext.current.instance.blogging_enabled?(@user) && @user.blog.present? && @user.blog.enabled? && !hide_tab?('blog_posts')
  end

  def published_posts
    @user.published_blogs.limit(5)
  end

  def reviews_collection_path
    routes.reviews_collections_path(@user)
  end

  def profile_url
    urlify(routes.profile_path(@user.slug))
  end

  def projects_profile_url_with_token
    urlify(routes.profile_path(@user.slug, token_key => @user.try(:temporary_token), anchor: :projects))
  end

  # url to the section in the application where a user can change his password
  def set_password_url_with_token
    routes.set_password_path(token_key => @user.try(:temporary_token))
  end

  # url to the section in the application where a user can change his password
  # with authentication token and tracking
  def set_password_url_with_token_and_tracking
    routes.set_password_path(token_key => @user.try(:temporary_token), :track_email_event => true)
  end

  # url for verifying (confirming) a user's email
  def verify_user_url
    routes.verify_user_path(@user.id, @user.email_verification_token, :track_email_event => true)
  end

  # url for verifying (confirming) a user's email
  def bookings_dashboard_url
    routes.dashboard_user_reservations_path
  end

  # url to the section in the application for managing a user's own bookings, with tracking
  def bookings_dashboard_url_with_tracking
    routes.dashboard_user_reservations_path(track_email_event: true)
  end

  # url to the section in the application for managing a user's own bookings, with authentication
  # token
  def bookings_dashboard_url_with_token
    routes.dashboard_user_reservations_path(token_key => @user.try(:temporary_token))
  end

  # url to the section in the application for managing a user's own bookings, with authentication
  # token, and tracking
  def bookings_dashboard_url_with_tracking_and_token
    routes.dashboard_user_reservations_path(token_key => @user.try(:temporary_token), track_email_event: true)
  end

  # listings in and around a user's location, limited to a 100 km radius and a maximum of 3 results
  def listings_in_near
    @user.listings_in_near(3, 100, true)
  end

  # the user's custom properties list
  def properties
    @user.properties
  end

  # url to the "big" version of a user's avatar image
  def avatar_url_big
    ActionController::Base.helpers.asset_url(@user.avatar_url(:big))
  end

  # url to the "thumb" version of a user's avatar image
  def avatar_url_thumb
    ActionController::Base.helpers.asset_url(@user.avatar_url(:thumb))
  end

  def avatar_url_bigger
    ActionController::Base.helpers.asset_url(@user.avatar_url(:bigger))
  end

  # url to a user's public profile
  def profile_path
    routes.profile_path(@user)
  end

  # url to the section in the application for sending a message to this user using the
  # marketplace's internal messaging system
  def user_message_path
    routes.new_user_user_message_path(user_id: @user.slug)
  end

  def user_blog_posts_list_path
    routes.user_blog_posts_list_path(@user)
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name', "children" => [<collection of chosen values] } }
  def categories
    if @categories.nil?
      @categories = build_categories_hash_for_object(@user, Category.users.roots.includes(:children))
    end
    @categories
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name>', "children" => 'string with all children separated with comma' } }
  def formatted_categories
    build_formatted_categories(@user)
  end

  # User's current address
  def address
    @user.current_address.presence || @user.locations.first.try(:location_address)
  end

  # Returns true if currently logged user is this user
  def is_current_user?
    @user.id == @context['current_user'].try(:id)
  end

  # Returns an array of custom attributes for seller profile
  def seller_attributes
    @user.seller_profile.instance_profile_type.custom_attributes.public_display
  end

  # Returns an array of custom attributes for buyer profile
  def buyer_attributes
    @user.buyer_profile.instance_profile_type.custom_attributes.public_display
  end

  # Returns an array of custom attributes for default profile
  def default_attributes
    @user.default_profile.instance_profile_type.custom_attributes.public_display
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
    @all_properties ||= @user.default_properties.to_h.merge(@user.seller_properties.to_h.merge(user.buyer_properties.to_h))
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
    I18n.l(@user.created_at.to_date, format: :short)
  end

  def completed_host_reservations_count
    @user.listing_reservations.reviewable.count
  end

  def click_to_call_button
    build_click_to_call_button_for_user(@user)
  end

  # whether or not the user has a buyer profile set up
  def has_buyer_profile?
    @user.buyer_profile.present?
  end

  # whether or not the user has a seller profile set up
  def has_seller_profile?
    @user.seller_profile.present?
  end

  # whether the user only has a buyer profile
  # implemented to make things easier as Liquid does not
  # have a not operator
  def only_buyer_profile?
    self.has_buyer_profile? && !self.has_seller_profile?
  end

  # whether the user only has a seller profile
  # implemented to make things easier as Liquid does not
  # have a not operator
  def only_seller_profile?
    !self.has_buyer_profile? && self.has_seller_profile?
  end

  private
    def social_connections
      @social_connections_cache ||= @user.social_connections
    end

end
