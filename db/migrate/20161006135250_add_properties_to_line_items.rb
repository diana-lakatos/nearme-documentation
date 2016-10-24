class AddPropertiesToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :properties, :text, default: nil
  end
end
