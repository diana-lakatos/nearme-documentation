class CorrectTabOverdueState < ActiveRecord::Migration
  def change
    i = Instance.find_by(id: 130)
    return true if i.nil?
    i.set_context!
    i.attributes = { my_orders_tabs: ['not_archived', 'archived'], orders_received_tabs: ['unconfirmed', 'confirmed', 'overdued', 'archived']}
    i.save(validate: false)
  end
end
