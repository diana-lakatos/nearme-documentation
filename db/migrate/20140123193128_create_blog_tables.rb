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

      t.timestamps
    end

    create_table :blog_posts do |t|
      t.string :title
      t.text :content

      t.integer :blog_instance_id
      t.integer :user_id

      t.timestamps
    end

    # NearMe instance
    BlogInstance.create(name: 'NearMe Blog', owner_type: 'near-me')
    Instance.where(name: 'DesksNearMe').each do |dnm_instance|
      dnm_blog = BlogInstance.new(name: 'DesksNearMe Blog')
      dnm_blog.owner_id = dnm_instance.id
      dnm_blog.owner_type = "Instance"
      dnm_blog.save!
    end

    add_column :instance_admin_roles, :permission_blog, :boolean, default: false
  end

  def down
    drop_table :blog_posts
    drop_table :blog_instances
    remove_column :instance_admin_roles, :permission_blog
  end
end
