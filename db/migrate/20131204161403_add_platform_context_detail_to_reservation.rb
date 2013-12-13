class AddPlatformContextDetailToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :platform_context_detail_id, :integer
    add_column :reservations, :platform_context_detail_type, :string
    add_index :reservations, :platform_context_detail_id
  end
end
