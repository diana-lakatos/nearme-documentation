# frozen_string_literal: true
class AddParametrizedNameToCustomModelTypes < ActiveRecord::Migration
  def up
    PlatformContext.current = nil
    add_column :custom_model_types, :parameterized_name, :string, index: true
    CustomModelType.reset_column_information
    CustomModelType.find_each { |cmt| cmt.update_column(:parameterized_name, CustomModelType.parameterize_name(cmt.name)) }
  end

  def down
    remove_column :custom_model_types, :parameterized_name
  end
end
