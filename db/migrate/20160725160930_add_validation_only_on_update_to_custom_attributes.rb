class AddValidationOnlyOnUpdateToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :validation_only_on_update, :boolean, default: false
  end
end
