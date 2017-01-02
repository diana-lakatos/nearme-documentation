class AddWithdrawInvitationWhenRejectingOfferToReservationTypes < ActiveRecord::Migration
  def change
    add_column :reservation_types, :withdraw_invitation_when_reject, :boolean
  end
end
