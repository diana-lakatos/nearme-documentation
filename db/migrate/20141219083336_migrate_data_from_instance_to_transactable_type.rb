class MigrateDataFromInstanceToTransactableType < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE transactable_types as tt
        SET service_fee_guest_percent = i.service_fee_guest_percent,
        service_fee_host_percent = i.service_fee_host_percent,
        bookable_noun = i.bookable_noun,
        lessor = i.lessor,
        lessee = i.lessee
      FROM instances i
      WHERE instance_id = i.id
    SQL
  end

  def down
  end
end
