class AddRegexToCustomValidator < ActiveRecord::Migration
  def change
    add_column :custom_validators, :regex_validation, :boolean, default: false, null: false
    add_column :custom_validators, :regex_expression, :string
  end
end
