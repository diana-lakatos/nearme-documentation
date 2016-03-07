class AddOfferCreatorIdToBids < ActiveRecord::Migration
  def change
    add_column :bids, :offer_creator_id, :integer, index: :true
  end
end
