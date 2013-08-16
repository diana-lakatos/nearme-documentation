class AddSourceAndCampaignToUsers < ActiveRecord::Migration
  def change
    add_column :users, :source, :string
    add_column :users, :campaign, :string
  end
end
