class InstanceAdmin::Analytics::ProfilesController < InstanceAdmin::Analytics::BaseController

  def show
    users = User.without(User.unscoped.admin).with_deleted.pluck('users.id, users.email, users.name,
      users.reservations_count, users.transactables_count, users.mobile_number,
      users.current_location, users.properties, users.created_at, users.deleted_at')

    csv = CSV.generate do |csv|
      csv.add_row %w(id email name bookings_count listings_count phone current_location user_properties created_at deleted_at)
      users.each do |profile|
        profile[-1] = value_to_utc(profile[-1])
        profile[-2] = value_to_utc(profile[-2])

        csv.add_row profile
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end

  end

  protected

  def value_to_utc(value)
    if value.present?
      return value.utc
    end

    value
  end

end
