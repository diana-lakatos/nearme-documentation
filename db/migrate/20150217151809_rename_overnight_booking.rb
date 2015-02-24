class RenameOvernightBooking < ActiveRecord::Migration
  def change
    rename_column :transactable_types, :overnight_booking, :action_overnight_booking
  end
end
