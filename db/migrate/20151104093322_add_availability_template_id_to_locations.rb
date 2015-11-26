class AddAvailabilityTemplateIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :availability_template_id, :integer
  end
end
