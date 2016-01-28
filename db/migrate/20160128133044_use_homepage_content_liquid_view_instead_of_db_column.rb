class UseHomepageContentLiquidViewInsteadOfDbColumn < ActiveRecord::Migration
  def up
    InstanceView.where(path: 'home/index', format: 'html', handler: 'liquid', partial: false).each do |iv|
      puts "Updating body for #{iv.path}(id=#{iv.id}) instance #{iv.instance_id}"
      iv.update_column(:body, iv.body.gsub('{{ platform_context.homepage_content }}', '{% include "home/homepage_content" %}'))
    end
  end

  def down
  end
end
