# frozen_string_literal: true
class CreateThirdPartyIntegrations < ActiveRecord::Migration
  def up
    create_table :third_party_integrations do |t|
      t.integer :instance_id, null: false
      t.string :type, null: false
      t.string :environment, null: false
      t.text :settings, null: false, default: '{}'
      t.index [:instance_id, :type, :environment], unique: true, name: 'unique'
    end
  end

  def down
    drop_table :third_party_integrations
  end
end
