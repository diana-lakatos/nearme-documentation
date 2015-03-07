class AddBuyableToTransactableTypes < ActiveRecord::Migration
  def up
    add_column :transactable_types, :buyable, :boolean

    TransactableType.reset_column_information

    TransactableType.all.each do |tt|
      PlatformContext.current = PlatformContext.new(tt.instance)
      tt.update_column :buyable, tt.name == 'Buy/Sell'
    end
  end

  def down
    remove_column :transactable_types, :buyable
  end
end
