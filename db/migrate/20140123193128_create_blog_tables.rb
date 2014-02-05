class CreateBlogTables < ActiveRecord::Migration

  class BlogInstance < ActiveRecord::Base
    belongs_to :owner, polymorphic: true
  end

  class Instance < ActiveRecord::Base
  end

  def up
    create_table :blog_instances do |t|
      t.string :name
      t.string :header
      t.integer :owner_id
      t.string :owner_type
      t.string :facebook_app_id
      t.boolean :enabled, default: false

      t.timestamps
    end

    create_table :blog_posts do |t|
      t.string :title
      t.text :content
      t.string :header

      t.string :author_name
      t.text :author_biography
      t.string :author_avatar

      t.integer :blog_instance_id
      t.integer :user_id

      t.string :slug
      t.datetime :published_at
      t.timestamps
    end

    # NearMe instance
    BlogInstance.create(name: 'NearMe Blog', owner_type: 'near-me')

    # DesksNearMe instances
    Instance.where(name: 'DesksNearMe').each do |dnm_instance|
      dnm_blog = BlogInstance.new(name: 'DesksNearMe Blog')
      dnm_blog.owner_id = dnm_instance.id
      dnm_blog.owner_type = "Instance"
      dnm_blog.save!
    end

    add_column :instance_admin_roles, :permission_blog, :boolean, default: false
    InstanceAdminRole.where(name: 'Administrator').update_all(permission_blog: true)
  end

  def down
    drop_table :blog_posts
    drop_table :blog_instances
    remove_column :instance_admin_roles, :permission_blog
  end
end
