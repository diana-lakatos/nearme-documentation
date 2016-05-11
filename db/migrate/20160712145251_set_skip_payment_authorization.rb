class SetSkipPaymentAuthorization < ActiveRecord::Migration
  def up
    TransactableType.unscoped.where(skip_payment_authorization: true).find_each do |tt|
      tt.instance.set_context!
      tt.reservation_type.skip_payment_authorization = true
      tt.reservation_type.save!
    end
  end
end
