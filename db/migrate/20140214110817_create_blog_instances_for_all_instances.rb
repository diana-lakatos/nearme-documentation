class CreateBlogInstancesForAllInstances < ActiveRecord::Migration
  class BlogInstance < ActiveRecord::Base
    belongs_to :owner, polymorphic: true
  end

  class Instance < ActiveRecord::Base
    has_one :blog_instance, :as => :owner
  end

  def up
    # Create blog for all instances that havent it yet
    Instance.all.each do |instance|
      next if instance.blog_instance.present?
      name = instance.name + " Blog"
      blog_instance = BlogInstance.new(name: name)
      blog_instance.owner_id = instance.id
      blog_instance.owner_type = "Instance"
      blog_instance.save!
    end
  end

  def down
  end
end
