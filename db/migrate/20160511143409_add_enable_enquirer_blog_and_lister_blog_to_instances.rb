class AddEnableEnquirerBlogAndListerBlogToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :enquirer_blogs_enabled, :boolean, default: false
    add_column :instances, :lister_blogs_enabled, :boolean, default: false
  end
end
