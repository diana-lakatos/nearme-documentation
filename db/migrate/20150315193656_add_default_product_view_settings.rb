class AddDefaultProductViewSettings < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE instances SET search_settings = search_settings || '"default_products_search_view"=>"products"'::hstore
    SQL
  end

  def down
  end
end
