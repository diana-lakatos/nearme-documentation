class InstanceAdmin::Analytics::SalesController < InstanceAdmin::Analytics::BaseController

  def show
    custom_properties_columns = CustomAttributes::CustomAttribute.with_deleted.where(
      target_type: 'TransactableType'
    ).pluck(:name).sort.uniq

    sql = 'SELECT reservations.*, ARRAY_AGG(reservation_periods.date) AS date, '\
    'hstore_to_json(transactables.properties) AS transactable_properties, '\
    'transactable_types.name AS transactable_type_name, '\
    'transactables.deleted_at AS transactable_deleted_at '\
    'FROM reservations '\
    'JOIN transactables '\
    'ON reservations.transactable_id = transactables.id '\
    'JOIN transactable_types '\
    'ON transactable_types.id = transactables.transactable_type_id '\
    'LEFT JOIN reservation_periods '\
    'ON reservation_periods.reservation_id = reservations.id '\
    "WHERE reservations.instance_id = #{platform_context.instance.id} "\
    "GROUP BY reservations.id, transactables.id, transactable_types.id"

    records_array = ActiveRecord::Base.connection.execute(sql)

    csv = CSV.generate do |csv|
      csv << [records_array.fields, custom_properties_columns].flatten

      records_array.each do |record|
        parsed_properties = {}
        begin
          parsed_properties = JSON.parse(record['transactable_properties'].to_s)
        rescue
          # Ignore, parsed_properties will be empty
        end

        values = record.values

        custom_properties_columns.each do |custom_property|
          values << parsed_properties[custom_property]
        end

        csv << values
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end

  end
end
