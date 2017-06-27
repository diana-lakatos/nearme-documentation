class ReplaceUtmSourceParameter < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      instance.set_context!

      Page.where('content like ?', '%utm_source=LUX%').find_each do |page|
        page.content = page.content.gsub('utm_source=LUX', 'utm_source={{ params.slug2 | raw_escape_string }}')
        page.save(validate: false)
      end

      ContentHolder.where('content like ?', '%utm_source=LUX%').find_each do |content_holder|
        content_holder.content = content_holder.content.gsub('utm_source=LUX', 'utm_source={{ params.slug2 | raw_escape_string }}')
        content_holder.save(validate: false)
      end
    end
  end

  def self.down
  end
end
