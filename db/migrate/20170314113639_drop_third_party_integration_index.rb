# frozen_string_literal: true
class DropThirdPartyIntegrationIndex < ActiveRecord::Migration
  def up
    remove_index :third_party_integrations, name: 'unique'
    add_index :third_party_integrations, [:instance_id, :type, :environment], name: 'third_party_integrations_index_on_instance_type'
  end

  def down
    add_index :third_party_integrations, [:instance_id, :type, :environment], unique: true, name: 'unique'
    remove_index :third_party_integrations, name: 'third_party_integrations_index_on_instance_type'
  end
end
