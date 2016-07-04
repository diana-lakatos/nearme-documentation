class DisableNoAction < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      TransactableType.find_each do |tt|
        tt.action_types.where(type: 'TransactableType::NoActionBooking').update_all(enabled: false) if tt.action_types.bookable.exists?
      end
    end
  end
end
