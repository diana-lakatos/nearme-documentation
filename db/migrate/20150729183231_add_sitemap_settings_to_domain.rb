class AddSitemapSettingsToDomain < ActiveRecord::Migration
  def up
    add_column :domains, :sitemap_enabled, :boolean, default: false
    add_column :domains, :generated_sitemap, :string
    add_column :domains, :uploaded_sitemap, :string
    add_column :domains, :uploaded_robots_txt, :string
  end

  def down
    remove_column :domains, :sitemap_enabled
    remove_column :domains, :generated_sitemap
    remove_column :domains, :uploaded_sitemap
    remove_column :domains, :uploaded_robots_txt
  end
end
