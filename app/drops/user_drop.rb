class UserDrop < BaseDrop

  include ActionView::Helpers::AssetUrlHelper
  include CategoriesHelper

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
  # current_location
  #   current location of the user
  delegate :id, :name, :friends, :friends_know_host_of, :mutual_friends, :know_host_of,
    :with_mutual_friendship_source, :first_name, :middle_name, :last_name,
    :email, :full_mobile_number, :administered_locations_pageviews_30_day_total, :blog,
    :country_name, :phone, :current_location, :is_trusted?, to: :user

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

  # url to a user's public profile
  def user_profile_url
    routes.profile_path(@user.slug)
  end

  def profile_url
    urlify(routes.profile_path(@user.slug))
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

  # User's current address
  def address
    @user.current_address.presence || @user.locations.first.try(:location_address)
  end
end
