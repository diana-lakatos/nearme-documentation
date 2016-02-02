class AddEnableLanguageSelectorToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :enable_language_selector, :boolean, :default => false, :null => false
  end
end
