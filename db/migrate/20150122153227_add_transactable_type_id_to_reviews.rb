class AddTransactableTypeIdToReviews < ActiveRecord::Migration
  def change
    add_reference :reviews, :transactable_type, index: true
  end
end
