class AddAvailableActionsToTransactables < ActiveRecord::Migration
  def up
    add_column :transactables, :available_actions, :string, array: true, default: []

    Transactable.reset_column_information
    Instance.find_each do |instance|
      instance.set_context!
      puts "Processing instance #{instance.name} - #{instance.id}"
      Transactable.unscoped.where(instance_id: instance.id).where("draft is NULL AND available_actions = '{}'").find_each do |t|
        if t.action_type && !t.action_type.is_a?(Transactable::NoActionBooking)
          t.update_column :available_actions, t.action_type.pricings.pluck(:unit).uniq
        end
      end
    end
  end

  def down
    remove_column :transactables, :available_actions
  end
end
