class AddRejectionReasonToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :rejection_reason, :string
  end
end
