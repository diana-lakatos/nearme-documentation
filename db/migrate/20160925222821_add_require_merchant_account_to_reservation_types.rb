class AddRequireMerchantAccountToReservationTypes < ActiveRecord::Migration
  def change
    add_column :reservation_types, :require_merchant_account, :boolean, default: false

    ReservationType.reset_column_information

    @instance = Instance.find_by(id: 195)
    @instance.reservation_types.update_all(require_merchant_account: true) if @instance
  end
end
