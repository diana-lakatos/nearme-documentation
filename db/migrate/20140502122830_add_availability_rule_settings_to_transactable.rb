class AddAvailabilityRuleSettingsToTransactable < ActiveRecord::Migration

  class TransactableType < ActiveRecord::Base
    serialize :availability_options, Hash
  end

  def up
    remove_column :transactables, :name
    remove_column :transactables, :description
    add_column :transactable_types, :availability_options, :text
    TransactableType.find_each do |tt|
      tt.update_attribute(:availability_options, { :confirm_reservations => { :default_value => true, :public => true } })
    end

    create_table :availability_templates do |t|
      t.integer :transactable_type_id
      t.integer :instance_id
      t.string :name
      t.string :description
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :availability_templates, [:instance_id, :transactable_type_id], :name => "availability_templates_on_instance_id_and_tt_id"

  end

  def down
    add_column :transactables, :name, :string
    add_column :transactables, :description, :text
    remove_column :transactable_types, :availability_options
    drop_table :availability_templates
  end
end
