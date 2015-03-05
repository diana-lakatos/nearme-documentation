class RemoveResponseColumnFromPayouts < ActiveRecord::Migration
  def change
    remove_column :payouts, :response, :text
  end
end
