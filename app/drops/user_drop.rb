class UserDrop < Liquid::Drop
  def initialize(user)
    @user = user
  end

  def name
    @user.name
  end

  def email
    @user.email
  end

  def first_name
    @user.first_name
  end

  def search_url
    Rails.application.routes.url_helpers.search_url
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
    h = Rails.application.routes.url_helpers
    h.new_user_session_url(:return_to => h.space_wizard_list_path)
  end

  def manage_locations_url
    Rails.application.routes.url_helpers.manage_location_url
  end

  def edit_user_registration_url
    Rails.application.routes.url_helpers.edit_user_registration_url
  end

  def full_mobile_number
    @user.full_mobile_number
  end

  def verify_user_url
    Rails.application.routes.url_helpers.verify_user_url(@user.id, @user.email_verification_token)
  end

  def instance_name
    @user.instance.name
  end
end
