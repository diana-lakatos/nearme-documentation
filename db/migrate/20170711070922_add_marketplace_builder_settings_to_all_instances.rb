class AddMarketplaceBuilderSettingsToAllInstances < ActiveRecord::Migration
  def change
    Instance.all.each do |instance|
      if instance.marketplace_builder_settings.nil?
        instance.update_attribute :marketplace_builder_settings, MarketplaceBuilderSettings.new(status: 'ready', manifest: {})
      end
    end
  end
end
