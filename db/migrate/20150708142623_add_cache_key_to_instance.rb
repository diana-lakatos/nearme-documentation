class AddCacheKeyToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :context_cache_key, :string
  end
end
