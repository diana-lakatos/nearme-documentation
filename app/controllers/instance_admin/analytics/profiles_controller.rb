class InstanceAdmin::Analytics::ProfilesController < InstanceAdmin::Analytics::BaseController

  def show
    users = User.pluck('users.id, users.email, users.name,
      users.reservations_count, users.transactables_count, users.mobile_number,
      users.current_location, users.properties')

    csv = CSV.generate do |csv|
      csv.add_row %w(id email name bookings_count listings_count phone current_location user_properties)
      users.each do |profile|
        csv.add_row profile
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end

  end
end
