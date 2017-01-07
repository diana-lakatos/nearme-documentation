class AddSocialMetaTagsToListingsShow < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      puts "At instance: #{instance.id}"
      instance.set_context!
      view = instance.instance_views.find_by(path: 'listings/show')
      if view
        new_text = <<-TAGS
{% content_for 'social_meta_tags' %}
  {% include 'shared/social_meta_for_object', object: listing, url: listing.show_path %}
{% endcontent_for %}
TAGS
        view.body = new_text + "\n" + view.body
        view.save(validate: false)
      end
    end
  end

  def self.down
  end
end
