class InstanceAdmin::Analytics::ProfilesController < InstanceAdmin::Analytics::BaseController

  def show
    sql = 'SELECT users.id, users.email, users.name, users.bookings_count, users.phone, country_name, mobile_number, current_location, user_instance_profiles.properties as user_properties '\
    'FROM user_instance_profiles '\
    'JOIN users '\
    'ON user_instance_profiles.user_id = users.id '\
    "WHERE user_instance_profiles.instance_id = #{platform_context.instance.id} "\

    records_array = ActiveRecord::Base.connection.execute(sql)

    csv = CSV.generate do |csv|
      csv << records_array.fields
      records_array.each do |record|
        csv << record.values
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end

  end
end
