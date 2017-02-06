# frozen_string_literal: true
class FixDeletedAtIndexForSlugs < ActiveRecord::Migration
  def self.up
    remove_index :friendly_id_slugs, name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope'
    add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope], name: :index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope, unique: true, where: '(deleted_at IS NULL)'
  end

  def self.down
    remove_index :friendly_id_slugs, name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope'
    add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope], name: :index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope, unique: true, where: '(deleted_at IS NULL)'
  end
end
