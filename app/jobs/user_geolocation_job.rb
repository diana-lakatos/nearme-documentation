class UserGeolocationJob < Job

  def after_initialize(user_id)
    @user_id = user_id
  end

  def perform
    user = User.find_by(id: @user_id)
    if user.try(:last_geolocated_location_latitude) && user.try(:last_geolocated_location_longitude)
      if user.current_address.blank?
        address = user.build_current_address
      else
        address = user.current_address
      end

      address.latitude = user.last_geolocated_location_latitude
      address.longitude = user.last_geolocated_location_longitude

      address.save!
    end
  end

end

