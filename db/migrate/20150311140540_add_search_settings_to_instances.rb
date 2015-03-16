class AddSearchSettingsToInstances < ActiveRecord::Migration
  class Instance < ActiveRecord::Base
  end

  def up
    change_column_default :instances, :default_search_view, 'mixed'
    change_column_default :instances, :searcher_type, 'geo'

    add_column :instances, :search_settings, :hstore, default: '', null: false

    Instance.where(default_search_view: [nil, '']).each { |instance| instance.update_column :default_search_view, 'mixed' }
    Instance.where(searcher_type: [nil, '']).each { |instance| instance.update_column :searcher_type, 'geo' }

    # Set default values
    execute <<-SQL
      UPDATE instances SET search_settings = search_settings || '"date_pickers"=>"0", "tt_select_type"=>"dropdown", "date_pickers_mode"=>"relative", "date_pickers_use_availability_rules"=>"1"'::hstore
    SQL
  end

  def down
    remove_column :instances, :search_settings
    change_column_default :instances, :searcher_type, nil
    change_column_default :instances, :default_search_view, nil
  end
end
