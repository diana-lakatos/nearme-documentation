class AddUserSetDimensionsToSpreeVariant < ActiveRecord::Migration
  def self.up
    add_column :spree_variants, :weight_user, :decimal,:precision => 8, :scale => 2
    add_column :spree_variants, :height_user, :decimal,:precision => 8, :scale => 2
    add_column :spree_variants, :width_user, :decimal,:precision => 8, :scale => 2
    add_column :spree_variants, :depth_user, :decimal,:precision => 8, :scale => 2

    execute "update spree_variants set weight_user = weight, height_user = height, width_user = width, depth_user = depth"
  end

  def self.down
    remove_column :spree_variants, :weight_user
    remove_column :spree_variants, :height_user
    remove_column :spree_variants, :width_user
    remove_column :spree_variants, :depth_user
  end
end
