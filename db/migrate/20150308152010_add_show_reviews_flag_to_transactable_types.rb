class AddShowReviewsFlagToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :show_reviews_if_both_completed, :boolean, default: false
  end
end
