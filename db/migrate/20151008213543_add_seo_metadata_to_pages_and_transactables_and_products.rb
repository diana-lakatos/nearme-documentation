class AddSeoMetadataToPagesAndTransactablesAndProducts < ActiveRecord::Migration
  def change
    add_column :pages, :metadata_title, :string
    add_column :pages, :metadata_meta_description, :string
  end
end
