class MakeConfirmReservationsTrueByDefault < ActiveRecord::Migration
  def change
    change_column :transactables, :confirm_reservations, :boolean, default: true
  end
end
