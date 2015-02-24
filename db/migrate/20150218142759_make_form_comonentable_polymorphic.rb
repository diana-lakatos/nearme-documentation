class MakeFormComonentablePolymorphic < ActiveRecord::Migration
	class FormComponent < ActiveRecord::Base
  end

  def up
  	rename_column :form_components, :transactable_type_id, :form_componentable_id
  	add_column :form_components, :form_componentable_type, :string
  	FormComponent.update_all(form_componentable_type: 'TransactableType')
  end

  def down
  	rename_column :form_components, :form_componentable_id, :transactable_type_id
  	remove_column :form_components, :form_componentable_type
  end
end
