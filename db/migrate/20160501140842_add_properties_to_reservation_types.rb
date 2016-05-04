class AddPropertiesToReservationTypes < ActiveRecord::Migration
  def change
    add_column :reservation_types, :settings, :hstore, default: ''
  end
end
