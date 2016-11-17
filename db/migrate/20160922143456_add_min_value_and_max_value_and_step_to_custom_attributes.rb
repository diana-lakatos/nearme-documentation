class AddMinValueAndMaxValueAndStepToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :properties, :hstore, default: '', null: false
  end
end
