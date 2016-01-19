class FixHomePageForMarketplaces < ActiveRecord::Migration
  def up
    InstanceView.where(path: ['layouts/theme_footer', 'layouts/theme_header', 'home/homepage_content']).update_all(view_type: 'view')
    old_paths = ["include 'home/search_button'", "include 'home/search_box'", "include 'shared/modules/latest_products.html'"]
    new_paths = ["include 'home/search_button.html'", "include 'home/search_box.html'", "include 'shared/modules/latest_products.html'"]
    InstanceView.find_each do |iv|
      old_paths.each_with_index do |path, index|
        if iv.body.include?(old_paths[index])
          puts "iv #{iv.path} for #{iv.instance_id} includes #{old_paths[index]} - updating to #{new_paths[index]}"
          iv.update_column(:body, iv.body.gsub(old_paths[index], new_paths[index]))
          puts "\tupdated to #{new_paths[index]}"
        end
      end
    end

    Instance.find_each do |i|
      i.set_context!
      puts "Processing #{i.name}"
      if i.theme.present? && !i.theme.homepage_content.blank? && InstanceView.where(instance_id: i.id, path: 'home/index', format: 'html', handler: 'liquid', partial: false).count.zero?
        puts "\thempty homepage_content and no InstanceView for index/home - creating it"
        homepage_template ||= InstanceView.first_or_initialize(instance_id: i.id, path: 'home/index', partial: false, format: 'html', handler: 'liquid', locale: 'en') do |view|
          view.view_type = 'view'
          view.body = <<-SQL
{% content_for 'hero' %}
  <div class="container-fluid">
    <div class="row-fluid">
      {% if platform_context.is_company_theme? %}
        {% include 'home/search_button.html' %}
      {% else %}
        {% include 'home/search_box.html' %}
      {% endif %}
    </div>
  </div>
{% endcontent_for %}

<section class="how-it-works">
  {% include 'shared/modules/latest_products.html' %}
  {% include 'home/homepage_content.html' %}
</section>

{% content_for 'domready' %}
  new Home.BackgroundController($('#hero'))
  new Home.Controller($('body'))
{% endcontent_for %}
          SQL
        end.save!
      end
      if i.theme.try(:homepage_content).present?
        puts "\tcreating homepage content liquid view based on theme.homepage_content column unless created"
        InstanceView.first_or_initialize(instance_id: i.id, path: 'home/homepage_content', partial: true, format: 'html', handler: 'liquid', locale: 'en') do |view|
          view.view_type = 'view'
          view.body = "<style>" + i.theme.homepage_css.html_safe + "</style>\n" + i.theme.homepage_content.html_safe
        end.save!
      end
    end
  end

  def down
  end

end

