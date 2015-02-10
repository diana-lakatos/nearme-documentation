class AddUnitOfMeasureToSpreeVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :unit_of_measure, :text, :default => 'imperial'
  end
end
