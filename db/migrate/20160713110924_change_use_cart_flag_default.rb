class ChangeUseCartFlagDefault < ActiveRecord::Migration
  def change
    change_column :instances, :use_cart, :boolean, default: false
  end
end
