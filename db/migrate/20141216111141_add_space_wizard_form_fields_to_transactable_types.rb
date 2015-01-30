class AddSpaceWizardFormFieldsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :onboarding_form_fields, :text

    create_table :form_components do |t|
      t.string :name
      t.string :form_type
      t.integer :instance_id, index: true
      t.integer :transactable_type_id, index: true
      t.text :form_fields
      t.datetime :deleted_at
    end
    add_index :form_components, [:instance_id, :transactable_type_id, :form_type], name: "ttfs_instance_tt_form_type"
  end
end
