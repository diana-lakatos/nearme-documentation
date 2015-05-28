class AddSearchRadiusToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :search_radius, :integer
  end
end
