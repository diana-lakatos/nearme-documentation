class AddOptionsForMarketplaceReleases < ActiveRecord::Migration
  def change
    add_column :marketplace_releases, :options, :json
  end
end
