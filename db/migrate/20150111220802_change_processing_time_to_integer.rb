class ChangeProcessingTimeToInteger < ActiveRecord::Migration
  class SpreeShippingMethod < ActiveRecord::Base
  end

  def up
    reversible do
      SpreeShippingMethod.update_all processing_time: '0'
    end

    change_column :spree_shipping_methods, :processing_time, 'integer USING CAST(processing_time AS integer)'
  end

  def down
    change_column :spree_shipping_methods, :processing_time, :string
  end
end
