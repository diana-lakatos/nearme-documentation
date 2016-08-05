class AddOrdersTabsToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :orders_received_tabs, :string
    add_column :instances, :my_orders_tabs, :string

    i = Instance.find('130')
    i.attributes = { my_orders_tabs: ['not_archived', 'archived'], orders_received_tabs: ['unconfirmed', 'confirmed', 'overdue', 'archived']}
    i.save(validate: false)
  end
end
