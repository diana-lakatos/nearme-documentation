class AddIndexesToTransactableDimensionsTempl < ActiveRecord::Migration
  def change
    add_index :deliveries, [:instance_id, :dimensions_template_id]
  end
end
