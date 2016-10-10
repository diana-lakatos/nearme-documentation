class InstanceAdmin::Analytics::ProfilesController < InstanceAdmin::Analytics::BaseController
  def show
    columns = %w(id email name sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip orders_count transactables_count phone browser browser_version platform last_geolocated_location_longitude last_geolocated_location_latitude time_zone language mobile_number created_at deleted_at)

    columns_str = columns.collect { |column| "users.#{column}" }.join(', ')

    sql = "SELECT #{columns_str}, addresses.formatted_address, hstore_to_json(default_up.properties) AS default_user_properties, hstore_to_json(buyer_up.properties) AS buyer_user_properties, hstore_to_json(seller_up.properties) AS seller_user_properties FROM users "\
      "LEFT JOIN addresses on addresses.entity_id = users.id and addresses.entity_type = 'User' AND addresses.instance_id = #{platform_context.instance.id} "\
      "LEFT JOIN user_profiles default_up on default_up.user_id = users.id AND default_up.profile_type = 'default' AND default_up.instance_id = #{platform_context.instance.id} "\
      "LEFT JOIN user_profiles buyer_up on buyer_up.user_id = users.id AND buyer_up.profile_type = 'buyer' AND buyer_up.instance_id = #{platform_context.instance.id} "\
      "LEFT JOIN user_profiles seller_up on seller_up.user_id = users.id AND seller_up.profile_type = 'seller' AND seller_up.instance_id = #{platform_context.instance.id} "\
      "WHERE users.instance_id = #{platform_context.instance.id} AND (users.admin = false OR users.admin IS NULL) "

    records_array = ActiveRecord::Base.connection.execute(sql)

    csv = CSV.generate do |csv|
      csv.add_row columns + %w(address default_properties buyer_properties seller_properties)
      records_array.each do |profile|
        csv.add_row profile.values
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end
  end
end
