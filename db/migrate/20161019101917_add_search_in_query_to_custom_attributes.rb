class AddSearchInQueryToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :search_in_query, :boolean, default: false, null: false
  end
end
