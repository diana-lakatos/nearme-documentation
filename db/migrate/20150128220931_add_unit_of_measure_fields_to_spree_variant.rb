class AddUnitOfMeasureFieldsToSpreeVariant < ActiveRecord::Migration
  def change
    add_column :spree_variants, :weight_unit, :string, :default => 'oz'
    add_column :spree_variants, :height_unit, :string, :default => 'in'
    add_column :spree_variants, :width_unit, :string, :default => 'in'
    add_column :spree_variants, :depth_unit, :string, :default => 'in'
  end
end
