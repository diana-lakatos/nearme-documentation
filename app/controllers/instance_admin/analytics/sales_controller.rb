class InstanceAdmin::Analytics::SalesController < InstanceAdmin::Analytics::BaseController

  def show
    sql = 'SELECT reservations.*, '\
    'transactables.name AS transactable_name, '\
    'transactables.description AS transactable_description, '\
    'transactables.properties AS transactable_properties '\
    'FROM reservations '\
    'JOIN transactables '\
    'ON reservations.transactable_id = transactables.id '\
    "WHERE reservations.instance_id = #{platform_context.instance.id} "\

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
