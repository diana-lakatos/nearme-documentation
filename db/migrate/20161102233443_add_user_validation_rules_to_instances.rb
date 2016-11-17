# frozen_string_literal: true
class AddUserValidationRulesToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :password_validation_rules, :text, default: { min_password_length: 6 }.to_yaml
  end
end
