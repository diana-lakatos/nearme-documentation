class InstanceAdmin::Analytics::ProfilesController < InstanceAdmin::Analytics::BaseController

  def show
    profiles = UserInstanceProfile.joins(:user).pluck('users.id, users.email, users.name,
      user_instance_profiles.reservations_count, user_instance_profiles.transactables_count, users.mobile_number,
      users.current_location, user_instance_profiles.properties')

    csv = CSV.generate do |csv|
      csv.add_row %w(id email name bookings_count listings_count phone country_name mobile_number current_location user_properties)
      profiles.each do |profile|
        csv.add_row profile
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end

  end
end
