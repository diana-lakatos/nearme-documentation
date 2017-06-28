# frozen_string_literal: true
class CreateAuthorizationPolicies < ActiveRecord::Migration
  def change
    create_table :authorization_policies do |t|
      t.string   :name
      t.string   :content
      t.integer  :instance_id, index: true
      t.timestamps
      t.datetime :deleted_at
      t.index [:instance_id, :name], unique: true, where: '(deleted_at IS NULL)'
    end

    create_table :authorization_policy_associations do |t|
      t.integer  :instance_id
      t.integer  :authorizable_id
      t.integer  :authorization_policy_id
      t.string   :authorizable_type
      t.timestamps
      t.index [:instance_id, :authorization_policy_id, :authorizable_id, :authorizable_type],
              unique: true, name: 'authorization_policy_association_unique_index'
    end
  end
end
