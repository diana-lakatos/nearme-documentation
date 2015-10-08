class DropIndexForPropertiesDueToCharacterLimit < ActiveRecord::Migration
  def up
    execute "DROP INDEX transactables_gin_properties"
    execute "DROP INDEX spree_products_gin_extra_properties"
  end

  def down
    execute "CREATE INDEX transactables_gin_properties ON transactables USING GIN(properties)"
    execute "CREATE INDEX spree_products_gin_extra_properties ON spree_products USING GIN(extra_properties)"
  end
end
