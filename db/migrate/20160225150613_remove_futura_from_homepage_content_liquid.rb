class RemoveFuturaFromHomepageContentLiquid < ActiveRecord::Migration
  def up
    puts "Removing Futura-demi from homepage content template"
    Instance.find_each do |i|
      i.set_context!
      text_to_remove = "\r\n\  font-family: \"Futura-demi\", sans-serif;"
      homepage_content_template = InstanceView.where(instance_id: i.id, path: 'home/homepage_content', partial: true, format: 'html', handler: 'liquid').first
      if homepage_content_template
        updated_text = homepage_content_template.body.gsub(text_to_remove, '')
        if updated_text != homepage_content_template.body
          homepage_content_template.update_column :body, updated_text
          puts "\tUpdated theme for #{i.name}"
        end
      end
    end
  end
  def down
  end
end
