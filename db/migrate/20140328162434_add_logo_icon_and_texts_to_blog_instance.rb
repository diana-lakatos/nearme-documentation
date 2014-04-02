class AddLogoIconAndTextsToBlogInstance < ActiveRecord::Migration
  def change
    add_column :blog_instances, :header_logo, :string
    add_column :blog_instances, :header_icon, :string
    add_column :blog_instances, :header_text, :string
    add_column :blog_instances, :header_motto, :string
  end
end
