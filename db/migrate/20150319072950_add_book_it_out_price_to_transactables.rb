class AddBookItOutPriceToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :book_it_out_discount, :integer
    add_column :transactables, :book_it_out_minimum_qty, :integer
  end
end
