class AddDefaultTimeZoneToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :time_zone, :string
  end
end
