# frozen_string_literal: true
class AddParameterizedNameToReservationType < ActiveRecord::Migration
  def up
    PlatformContext.current = nil
    add_column :reservation_types, :parameterized_name, :string, index: true
    ReservationType.reset_column_information
    ReservationType.find_each { |rt| rt.update_column(:parameterized_name, ReservationType.parameterize_name(rt.name)) }
  end

  def down
    remove_column :reservation_types, :parameterized_name
  end
end
