class Instance < ActiveRecord::Base
  DEFAULT_INSTANCE_NAME = 'DesksNearMe'

  def self.default_instance
    self.find_by_name(DEFAULT_INSTANCE_NAME)
  end

  def is_desksnearme?
    self.name == DEFAULT_INSTANCE_NAME
  end
end

class AddDefaultToInstances < ActiveRecord::Migration
  def up
    add_column :instances, :default_instance, :boolean, default: false
    
    Instance.default_instance.update_attribute(:default_instance, true) if Instance.default_instance
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
