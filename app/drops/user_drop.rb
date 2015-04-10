class UserDrop < BaseDrop

  include ActionView::Helpers::AssetUrlHelper

  attr_reader :user
  delegate :name, :friends, :friends_know_host_of, :mutual_friends, :know_host_of, :with_mutual_friendship_source, :job_title, :first_name, :email, :full_mobile_number, :administered_locations_pageviews_30_day_total, to: :user

  def initialize(user)
    @user = user
  end

  def display_location
    @user.decorate.display_location
  end

  def name_pluralize
    name.pluralize
  end

  def first_name_pluralize
    first_name.pluralize
  end

  def public_profile?
    @user.public_profile
  end

  def facebook_connections
    @user.decorate.social_connections_for('facebook').present?
  end

  def linkedin_connections
    @user.decorate.social_connections_for('linkedin').present?
  end

  def twitter_connections
    @user.decorate.social_connections_for('twitter').present?
  end

  def search_url
    routes.search_path
  end

  def search_url_with_tracking
    routes.search_path(track_email_event: true)
  end

  def reservation_city?
    @user.reservations.first.listing.location[:city].present?
  end

  def reservation_city
    @user.reservations.first.listing.location.city
  end

  def reservation_name
    self.reservation_city? ? @user.reservations.first.listing.location.city : @user.reservations.first.listing.location.name
  end

  def space_wizard_list_path
    routes.new_user_session_path(:return_to => routes.space_wizard_list_path)
  end

  def space_wizard_list_url_with_tracking
    routes.space_wizard_list_path(token: @user.try(:temporary_token), track_email_event: true)
  end

  def manage_locations_url
    routes.dashboard_company_transactable_types_path
  end

  def manage_locations_url_with_tracking
    routes.dashboard_company_transactable_types_path(track_email_event: true)
  end

  def manage_locations_url_with_tracking_and_token
    routes.dashboard_company_transactable_types_path(token: @user.try(:temporary_token), track_email_event: true)
  end

  def edit_profile_path
    routes.dashboard_profile_path
  end

  def edit_user_registration_url(with_token = false)
    routes.edit_user_registration_path(:token => @user.try(:temporary_token))
  end

  def edit_user_registration_url_with_token
    routes.edit_user_registration_path(:token => @user.try(:temporary_token))
  end

  def edit_user_registration_url_with_token_and_tracking
    routes.edit_user_registration_path(:token => @user.try(:temporary_token), :track_email_event => true)
  end

  def user_profile_url
    routes.profile_path(@user.slug)
  end

  def set_password_url_with_token
    routes.set_password_path(:token => @user.try(:temporary_token))
  end

  def set_password_url_with_token_and_tracking
    routes.set_password_path(:token => @user.try(:temporary_token), :track_email_event => true)
  end

  def verify_user_url
    routes.verify_user_path(@user.id, @user.email_verification_token, :track_email_event => true)
  end

  def bookings_dashboard_url
    routes.dashboard_user_reservations_path
  end

  def bookings_dashboard_url_with_tracking
    routes.dashboard_user_reservations_path(track_email_event: true)
  end

  def bookings_dashboard_url_with_token
    routes.dashboard_user_reservations_path(token: @user.try(:temporary_token))
  end

  def bookings_dashboard_url_with_tracking_and_token
    routes.dashboard_user_reservations_path(token: @user.try(:temporary_token), track_email_event: true)
  end

  def listings_in_near
    @user.listings_in_near(3, 100, true)
  end

  def properties
    @user.properties
  end

  def avatar_url_big
    ActionController::Base.helpers.asset_url(@user.avatar_url(:big))
  end

  def profile_path
    routes.profile_path(@user)
  end

  def user_message_path
    routes.new_user_user_message_path(user_id: @user.slug)
  end
end

