class AddAverageRatingToTransactable < ActiveRecord::Migration
  def change
    add_column :transactables, :average_rating, :float, :default => 0.0
  end
end
