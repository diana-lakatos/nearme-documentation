class AddPricesToTransactables < ActiveRecord::Migration
  def up
    add_column :transactables, :hourly_price_cents, :integer, default: 0
    add_column :transactables, :daily_price_cents, :integer, default: 0
    add_column :transactables, :weekly_price_cents, :integer, default: 0
    add_column :transactables, :monthly_price_cents, :integer, default: 0

    Transactable.connection.execute <<-SQL
      UPDATE transactables
      SET properties = properties || '"daily_price_cents"=>""'::hstore
      WHERE properties->'daily_price_cents' LIKE 'a' OR properties->'daily_price_cents' LIKE '$ 400'
    SQL
    expression = "%name% = NULLIF(properties->'%name%', '')::int"
    connection.execute <<-SQL
      UPDATE transactables
      SET
        #{expression.gsub('%name%', 'daily_price_cents')},
        #{expression.gsub('%name%', 'weekly_price_cents')},
        #{expression.gsub('%name%', 'hourly_price_cents')},
        #{expression.gsub('%name%', 'monthly_price_cents')}
    SQL

  end

  def down
    remove_column :transactables, :daily_price_cents
    remove_column :transactables, :hourly_price_cents
    remove_column :transactables, :weekly_price_cents
    remove_column :transactables, :monthly_price_cents
  end
end