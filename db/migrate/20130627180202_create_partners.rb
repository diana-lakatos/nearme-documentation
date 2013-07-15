class CreatePartners < ActiveRecord::Migration

  def up
    create_table :partners do |t|
      t.string :name
      t.decimal :service_fee_percent, :precision => 5, :scale => 2, :default => 0

      t.timestamps
    end

    connection.execute <<-SQL
      INSERT INTO partners (name, service_fee_percent, created_at, updated_at)
      VALUES ('Desks Near Me', 10.0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
  end

  def down
    drop_table :partners
  end
end
