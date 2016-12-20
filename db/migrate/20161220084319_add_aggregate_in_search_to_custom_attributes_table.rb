class AddAggregateInSearchToCustomAttributesTable < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :aggregate_in_search, :boolean, default: false
  end
end
