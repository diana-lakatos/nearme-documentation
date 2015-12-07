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
      [
        { "Help" => 'https://software.intel.com/en-us/support?source=devmesh'},
        {"Terms of Service"=> 'http://www.intel.com/content/www/us/en/legal/terms-of-use.html'},
        {"Trademarks"=> 'http://www.intel.com/content/www/us/en/legal/trademarks.html'},
        { "Privacy" => 'http://www.intel.com/content/www/us/en/privacy/intel-online-privacy-notice-summary.html'},
        { "Cookies" => 'http://www.intel.com/content/www/us/en/privacy/intel-cookie-notice.html' }
      ].each do |page|
        page.each do |text, url|
          Page.new(path: text, instance_id: i, theme_id: PlatformContext.current.theme.id, redirect_url: url, redirect_code: 301).save!
        end
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

      ipt.custom_attributes.where(name: 'about_me').first_or_initialize.tap do |ca|
        ca.public = true
        ca.html_tag = 'textarea'
        ca.attribute_type = 'text'
        ca.input_html_options = { cols: 40, rows: 8 }
        ca.label = 'About me'
      end.save!

      ipt.custom_attributes.where(name: 'short_bio').first_or_initialize.tap do |ca|
        ca.public = true
        ca.html_tag = 'textarea'
        ca.attribute_type = 'text'
        ca.input_html_options = { cols: 40, rows: 8 }
        ca.label = 'Short Bio'
      end.save!



      Utils::DefaultAlertsCreator::ProjectCreator.new.create_all!
      PlatformContext.current.theme.update_attributes(
        facebook_url: 'https://www.facebook.com/IntelDeveloperZone/',
        twitter_url: 'https://twitter.com/intelsoftware',
        gplus_url: 'href="https://plus.google.com/+IntelSoftware/posts',
        instagram_url: 'https://instagram.com/inteldeveloperzone'
      )
    end
    Rails.cache.clear
  end
end
