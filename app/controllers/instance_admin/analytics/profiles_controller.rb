class InstanceAdmin::Analytics::ProfilesController < InstanceAdmin::Analytics::BaseController

  def show
    sql = 'SELECT users.id, users.email, users.name,
          (SELECT count(1) FROM reservations WHERE owner_id = users.id AND reservations.deleted_at IS NULL) AS bookings_count, '\
          '(SELECT COUNT(1) FROM transactables INNER JOIN locations ON transactables.location_id = locations.id '\
          'INNER JOIN companies ON locations.company_id = companies.id INNER JOIN company_users ON companies.id = company_users.company_id '\
          'WHERE transactables.deleted_at IS NULL AND locations.deleted_at IS NULL AND companies.deleted_at IS NULL AND '\
          'company_users.deleted_at IS NULL AND company_users.user_id = users.id) AS listings_count, '\
          'users.phone, country_name, mobile_number, current_location, '\
          'user_instance_profiles.properties as user_properties '\
          'FROM user_instance_profiles JOIN users ON user_instance_profiles.user_id = users.id WHERE '\
          "user_instance_profiles.instance_id = #{platform_context.instance.id}"

    records_array = ActiveRecord::Base.connection.execute(sql)

    csv = CSV.generate do |csv|
      csv.add_row records_array.fields
      records_array.each do |record|
        csv.add_row record.values
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end

  end
end
