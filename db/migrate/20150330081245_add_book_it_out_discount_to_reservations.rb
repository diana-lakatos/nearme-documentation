class AddBookItOutDiscountToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :book_it_out_discount, :integer
  end
end
