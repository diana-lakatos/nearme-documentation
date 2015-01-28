class AddEnableReviewsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :enable_reviews, :boolean
  end
end
