class AddUrlToMarketplaceErrors < ActiveRecord::Migration
  def change
    add_column :marketplace_errors, :url, :string
  end
end
