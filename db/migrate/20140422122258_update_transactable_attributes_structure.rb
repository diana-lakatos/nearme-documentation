class UpdateTransactableAttributesStructure < ActiveRecord::Migration

  def up
    add_column :transactable_type_attributes, :label, :string
    add_column :transactable_type_attributes, :input_html_options, :text
    add_column :transactable_type_attributes, :wrapper_html_options, :text
    add_column :transactable_type_attributes, :hint, :text
    add_column :transactable_type_attributes, :placeholder, :string
  end

  def down
    remove_column :transactable_type_attributes, :label
    remove_column :transactable_type_attributes, :input_html_options
    remove_column :transactable_type_attributes, :wrapper_html_options
    remove_column :transactable_type_attributes, :hint
    remove_column :transactable_type_attributes, :placeholder
  end
end
