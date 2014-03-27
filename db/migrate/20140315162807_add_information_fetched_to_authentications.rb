class AddInformationFetchedToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :information_fetched, :datetime
  end
end
