class UserDrop < BaseDrop
  def initialize(user)
    @user = user
  end

  def name
    @user.name
  end

  def first_name
    @user.first_name
  end

  def email
    @user.email
  end

  def name_pluralize
    name.pluralize
  end

  def first_name_pluralize
    first_name.pluralize
  end

  def search_url
    routes.search_url
  end

  def search_url_with_tracking
    routes.search_url(track_email_event: true)
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
    routes.new_user_session_url(:return_to => routes.space_wizard_list_path)
  end

  def space_wizard_list_url_with_tracking
    routes.space_wizard_list_url(token: @user.authentication_token, track_email_event: true)
  end

  def manage_locations_url
    routes.manage_locations_url
  end

  def manage_locations_url_with_tracking
    routes.manage_locations_url(track_email_event: true)
  end

  def manage_locations_url_with_tracking_and_token
    routes.manage_locations_url(token: @user.authentication_token, track_email_event: true)
  end

  def edit_user_registration_url(with_token = false)
    routes.edit_user_registration_url(:token => @user.authentication_token)
  end

  def edit_user_registration_url_with_token
    routes.edit_user_registration_url(:token => @user.authentication_token)
  end

  def user_profile_url
    routes.profile_url(@user.slug)
  end

  def set_password_url_with_token
    routes.set_password_url(:token => @user.authentication_token)
  end

  def full_mobile_number
    @user.full_mobile_number
  end

  def verify_user_url
    routes.verify_user_url(@user.id, @user.email_verification_token)
  end

  def listings_in_near
    @user.listings_in_near
  end

  def administered_locations_pageviews_7_day_total
    @user.administered_locations_pageviews_7_day_total
  end

  def bookings_dashboard_url
    routes.bookings_dashboard_url
  end

  def bookings_dashboard_url_with_tracking
    routes.bookings_dashboard_url(track_email_event: true)
  end

  def bookings_dashboard_url_with_token
    routes.bookings_dashboard_url(token: @user.authentication_token)
  end

  def bookings_dashboard_url_with_tracking_and_token
    routes.bookings_dashboard_url(token: @user.authentication_token, track_email_event: true)
  end
end
