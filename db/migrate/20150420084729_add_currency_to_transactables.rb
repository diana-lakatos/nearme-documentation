class AddCurrencyToTransactables < ActiveRecord::Migration
  def up
    add_column :transactables, :currency, :string

    connection.execute <<-SQL
      UPDATE transactables
      SET
        currency = locations.currency
      FROM locations
      WHERE locations.id = transactables.location_id
    SQL

  end

  def down
    remove_column :transactables, :currency
  end
end
