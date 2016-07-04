class AddHeadersToReverseProxies < ActiveRecord::Migration
  def change
    add_column :reverse_proxies, :headers, :text, default: '{}'
  end
end
