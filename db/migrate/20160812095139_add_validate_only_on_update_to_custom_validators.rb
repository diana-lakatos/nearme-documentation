class AddValidateOnlyOnUpdateToCustomValidators < ActiveRecord::Migration
  def change
    add_column :custom_validators, :validation_only_on_update, :boolean, default: false
  end
end
