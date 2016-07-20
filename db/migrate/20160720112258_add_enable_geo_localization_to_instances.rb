class AddEnableGeoLocalizationToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :enable_geo_localization, :boolean, nil: false, default: true
  end
end
