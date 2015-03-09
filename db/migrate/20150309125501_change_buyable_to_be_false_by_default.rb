class ChangeBuyableToBeFalseByDefault < ActiveRecord::Migration
  def change
    change_column :transactable_types, :buyable, :boolean, default: false
  end
end
