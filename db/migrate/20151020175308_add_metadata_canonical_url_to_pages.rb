class AddMetadataCanonicalUrlToPages < ActiveRecord::Migration
  def change
    add_column :pages, :metadata_canonical_url, :string
  end
end
