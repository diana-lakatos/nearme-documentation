namespace :intel do
  desc "Setup intel"
  task :setup => [:environment] do
    Utils::EnLocalesSeeder.new.go!
    Instance.where(is_community: true).find_each do |i|
      puts "Processing #{i.name} - adding project type, categories, topics if needed"
      i.set_context!
      InstanceView.where(instance_id: i, path: 'home/index').destroy_all

      i.update_attributes({name: 'Intel'})

      puts "Processing #{i.name} - adding dummy pages"
      Page.where(instance_id: i).destroy_all
      ["Help", "Terms of Service", "Trademarks", "Privacy", "Cookies"].each do |page_name|
        Page.new(path: page_name, instance_id: i, theme_id: PlatformContext.current.theme.id ).save!
      end

      project_type = ProjectType.first || ProjectType.create(name: 'Project')
      ['Real Sense', 'Android', 'Open Source', 'Big Data', 'Networking', 'Dual Screen'].each do |topic_name|
        category = project_type.categories.where(name: topic_name).first_or_initialize.tap do |c|
          c.shared_with_users = true
        end
        category.save!
        Topic.where(name: topic_name).first_or_initialize.tap do |t|
          t.category = category
          t.description = "Quisque euismod orci sed nisi malesuada porta. In non molestie purus. Sed ut maximus nibh, eu ultrices massa. In accum san augue nisl, eget ultrices"
        end.save!
      end

      ipt = InstanceProfileType.default.first
      ipt.custom_attributes.where(name: 'role').first_or_initialize.tap do |ca|
        ca.public = false
        ca.valid_values = ['Black Belt', 'Innovator', 'Featured', 'Other']
        ca.html_tag = 'select'
        ca.attribute_type = 'string'
        ca.label = 'Role'
      end.save!

      ipt.custom_attributes.where(name: 'biography').first_or_initialize.tap do |ca|
        ca.public = true
        ca.html_tag = 'textarea'
        ca.attribute_type = 'text'
        ca.input_html_options = { cols: 40, rows: 8 }
        ca.label = 'Biography'
      end.save!
      Utils::DefaultAlertsCreator::ProjectCreator.new.create_all!
    end
    Rails.cache.clear
  end
end
