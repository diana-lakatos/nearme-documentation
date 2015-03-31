class AddBookItOutToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_book_it_out, :boolean
  end
end
