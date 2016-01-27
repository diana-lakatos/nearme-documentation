class RemoveDomreadyFromLiquid < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      puts "Processing #{i.name}"
      homepage_body_text_to_remove = "{% content_for 'domready' %}\r\n  new Home.BackgroundController($('#hero'))\r\n  new Home.Controller($('body'))\r\n{% endcontent_for %}"
      homepage_body_text_to_remove2 = "{% content_for 'domready' %}\n  new Home.BackgroundController($('#hero'))\n  new Home.Controller($('body'))\n{% endcontent_for %}\n"
      blogindex_body_text_to_remove = "<script>\r\n  $(function() {\r\n    new BlogPostsController();\r\n  });\r\n</script>\r\n"
      homepage_template = InstanceView.where(instance_id: i.id, path: 'home/index', partial: false, format: 'html', handler: 'liquid').first
      if homepage_template
        homepage_template.update_column :body, homepage_template.body.gsub(homepage_body_text_to_remove, '').gsub(homepage_body_text_to_remove2, '')
        puts "\tupdating home page template"
      end
      blogindex_template = InstanceView.where(instance_id: i.id, path: 'blog/blog_posts/index', partial: false, format: 'html', handler: 'liquid').first
      if blogindex_template
        blogindex_template.update_column :body, blogindex_template.body.gsub(blogindex_body_text_to_remove, '')
        puts "\tupdating blog index template"
      end
    end
  end
  def down
  end
end
