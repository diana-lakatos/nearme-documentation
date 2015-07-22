class AddExpressTokenToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :express_token, :string
    add_column :reservations, :express_payer_id, :string
  end
end
