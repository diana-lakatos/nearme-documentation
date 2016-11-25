# frozen_string_literal: true
class AddImpressionsIndices < ActiveRecord::Migration
  def change
    add_index 'impressions', [:instance_id, :impressionable_id, :impressionable_type], name: 'index_impressions_scope', using: :btree
    add_index 'impressions', [:created_at], using: :btree

    remove_index 'impressions', ['company_id']
    remove_index 'impressions', %w(impressionable_type impressionable_id)
    remove_index 'impressions', ['instance_id']
    remove_index 'impressions', ['partner_id']
  end
end
