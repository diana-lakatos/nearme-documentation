class AddUiVersionToFormComponents < ActiveRecord::Migration
  def change
    add_column :form_components, :ui_version, :string
  end
end
