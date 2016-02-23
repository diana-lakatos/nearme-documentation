class AddStateToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :state, :string, index: true
  end
end
