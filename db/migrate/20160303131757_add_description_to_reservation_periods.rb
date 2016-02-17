class AddDescriptionToReservationPeriods < ActiveRecord::Migration
  def change
    add_column :reservation_periods, :description, :string
  end
end
